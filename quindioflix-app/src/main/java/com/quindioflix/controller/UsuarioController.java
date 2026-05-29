package com.quindioflix.controller;

import com.quindioflix.dto.CambiarPlanPagoDTO;
import com.quindioflix.dto.CrearPerfilDTO;
import com.quindioflix.dto.PagoPlanResponseDTO;
import com.quindioflix.dto.UsuarioPublicoDTO;
import com.quindioflix.dto.UsuarioResumenDTO;
import com.quindioflix.model.Perfil;
import com.quindioflix.model.Plan;
import com.quindioflix.model.Usuario;
import com.quindioflix.model.Pago;
import com.quindioflix.repository.PerfilRepository;
import com.quindioflix.repository.PlanRepository;
import com.quindioflix.repository.ReproduccionRepository;
import com.quindioflix.repository.UsuarioRepository;
import com.quindioflix.repository.PagoRepository;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/usuarios")
@RequiredArgsConstructor
public class UsuarioController {

    private final UsuarioRepository usuarioRepository;
    private final PerfilRepository perfilRepository;
    private final ReproduccionRepository reproduccionRepository;
    private final PagoRepository pagoRepository;
    private final PlanRepository planRepository;

    @GetMapping
    public Page<UsuarioPublicoDTO> listarUsuarios(@RequestParam(defaultValue = "0") int page,
                                                  @RequestParam(defaultValue = "10") int size) {
        return usuarioRepository.findAll(PageRequest.of(page, size))
                .map(u -> UsuarioPublicoDTO.builder()
                        .id(u.getId())
                        .nombreCompleto(u.getNombreCompleto())
                        .email(u.getEmail())
                        .idCiudad(u.getIdCiudad())
                        .estadoCuenta(u.getEstadoCuenta())
                        .plan(u.getPlan() != null ? u.getPlan().getNombrePlan() : "NO TIENE SUSCRIPCION")
                        .build());
    }

    @GetMapping("/{id}/resumen")
    public ResponseEntity<UsuarioResumenDTO> obtenerResumen(@PathVariable Long id) {
        Usuario usuario = usuarioRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado con ID " + id));

        List<Perfil> perfiles = perfilRepository.findAll()
                .stream()
                .filter(p -> p.getUsuario().getId().equals(id))
                .toList();

        Long totalReprod = reproduccionRepository.countByPerfilUsuarioId(id);

        UsuarioResumenDTO dto = UsuarioResumenDTO.builder()
                .id(usuario.getId())
                .nombreCompleto(usuario.getNombreCompleto())
                .email(usuario.getEmail())
                .plan(usuario.getPlan() != null ? usuario.getPlan().getNombrePlan() : "NO TIENE SUSCRIPCION")
                .idPlan(usuario.getPlan() != null ? usuario.getPlan().getId() : null)
                .ciudad(null) // simplificado, ciudad se maneja como id en la entidad
                .estadoCuenta(usuario.getEstadoCuenta())
                .perfiles(perfiles.stream()
                        .map(p -> UsuarioResumenDTO.PerfilDTO.builder()
                                .id(p.getId())
                                .nombre(p.getNombrePerfil())
                                .tipo(p.getTipoPerfil())
                                .build())
                        .toList())
                .totalReproducciones(totalReprod)
                .build();

        return ResponseEntity.ok(dto);
    }

    @GetMapping("/{id}/pagos")
    public List<Pago> obtenerPagos(@PathVariable Long id) {
        return pagoRepository.findByUsuarioIdOrderByFechaPagoDesc(id);
    }

    @Transactional
    @PostMapping("/{id}/cambiar-plan")
    public ResponseEntity<Void> cambiarPlan(@PathVariable Long id,
                                            @RequestParam("nuevoPlanId") Long nuevoPlanId) {
        usuarioRepository.cambiarPlanSuscripcion(id, nuevoPlanId);
        return ResponseEntity.noContent().build();
    }

    @Transactional
    @PostMapping("/{id}/cambiar-plan-pago")
    public ResponseEntity<PagoPlanResponseDTO> cambiarPlanConPago(@PathVariable Long id,
                                                                  @Valid @RequestBody CambiarPlanPagoDTO dto) {
        Usuario usuario = usuarioRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        if (usuario.getEmail() != null && usuario.getEmail().toLowerCase().contains("admin")) {
            throw new RuntimeException("La cuenta administrador no tiene plan de suscripcion");
        }
        Plan planNuevo = planRepository.findById(dto.getNuevoPlanId())
                .orElseThrow(() -> new RuntimeException("Plan no encontrado"));

        // Validar que el usuario no tenga más perfiles de los que permite el nuevo plan
        int perfilesActuales = perfilRepository.countByUsuario_Id(id);
        if (planNuevo.getMaxPerfiles() != null && perfilesActuales > planNuevo.getMaxPerfiles()) {
            throw new RuntimeException(
                "Tienes " + perfilesActuales + " perfiles activos. El plan " + planNuevo.getNombrePlan()
                + " solo permite " + planNuevo.getMaxPerfiles() + ". Elimina perfiles antes de cambiar.");
        }

        String planAnterior = usuario.getPlan() != null ? usuario.getPlan().getNombrePlan() : "—";
        String tarjetaLimpia = dto.getNumeroTarjeta().replaceAll("\\s", "");
        if (tarjetaLimpia.length() < 13) {
            throw new RuntimeException("Numero de tarjeta invalido");
        }

        usuarioRepository.cambiarPlanSuscripcion(id, dto.getNuevoPlanId());

        LocalDate hoy = LocalDate.now();
        Pago pago = pagoRepository.save(Pago.builder()
                .usuario(usuario)
                .fechaPago(hoy)
                .fechaVencimiento(hoy.plusMonths(1))
                .monto(planNuevo.getPrecioMensual())
                .metodoPago(dto.getMetodoPago() != null ? dto.getMetodoPago() : "TARJETA_CREDITO")
                .estadoPago("EXITOSO")
                .build());

        usuario.setFechaUltimoPago(hoy);
        usuario.setEstadoCuenta("ACTIVO");
        usuarioRepository.save(usuario);

        String ref = "TXN-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        return ResponseEntity.ok(PagoPlanResponseDTO.builder()
                .idPago(pago.getId())
                .estadoPago("EXITOSO")
                .monto(pago.getMonto())
                .planAnterior(planAnterior)
                .planNuevo(planNuevo.getNombrePlan())
                .referenciaTransaccion(ref)
                .mensaje("Pago aprobado. Plan actualizado a " + planNuevo.getNombrePlan())
                .build());
    }

    @Transactional
    @PostMapping("/{id}/perfiles")
    public ResponseEntity<UsuarioResumenDTO.PerfilDTO> crearPerfil(@PathVariable Long id,
                                                                   @Valid @RequestBody CrearPerfilDTO dto) {
        Usuario usuario = usuarioRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        
        Plan plan = usuario.getPlan();
        if (plan == null) {
            throw new RuntimeException("El usuario no tiene un plan activo.");
        }

        int cantidadActual = perfilRepository.countByUsuario_Id(id);
        if (cantidadActual >= plan.getMaxPerfiles()) {
            throw new RuntimeException(
                "Máximo de perfiles alcanzado. Tu plan " + plan.getNombrePlan()
                + " permite hasta " + plan.getMaxPerfiles() + " perfiles.");
        }

        Perfil perfil = Perfil.builder()
                .usuario(usuario)
                .nombrePerfil(dto.getNombre())
                .tipoPerfil(dto.getTipo())
                .avatar("avatar.png") // Avatar por defecto
                .build();
        
        perfil = perfilRepository.save(perfil);

        UsuarioResumenDTO.PerfilDTO perfilRespuesta = UsuarioResumenDTO.PerfilDTO.builder()
                .id(perfil.getId())
                .nombre(perfil.getNombrePerfil())
                .tipo(perfil.getTipoPerfil())
                .build();

        return ResponseEntity.ok(perfilRespuesta);
    }

    @Transactional
    @DeleteMapping("/{id}/perfiles/{perfilId}")
    public ResponseEntity<Void> eliminarPerfil(@PathVariable Long id,
                                                @PathVariable Long perfilId) {
        Usuario usuario = usuarioRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        Perfil perfil = perfilRepository.findById(perfilId)
                .orElseThrow(() -> new RuntimeException("Perfil no encontrado"));

        // Validar que el perfil pertenece al usuario
        if (!perfil.getUsuario().getId().equals(id)) {
            throw new RuntimeException("Este perfil no pertenece a tu cuenta.");
        }

        // No dejar eliminar si solo queda 1 perfil
        int cantidadActual = perfilRepository.countByUsuario_Id(id);
        if (cantidadActual <= 1) {
            throw new RuntimeException("Debes tener al menos un perfil activo.");
        }

        perfilRepository.delete(perfil);
        return ResponseEntity.noContent().build();
    }
}
