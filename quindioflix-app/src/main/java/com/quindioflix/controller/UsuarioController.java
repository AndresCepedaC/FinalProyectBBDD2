package com.quindioflix.controller;

import com.quindioflix.dto.UsuarioPublicoDTO;
import com.quindioflix.dto.UsuarioResumenDTO;
import com.quindioflix.model.Perfil;
import com.quindioflix.model.Usuario;
import com.quindioflix.model.Pago;
import com.quindioflix.repository.PerfilRepository;
import com.quindioflix.repository.ReproduccionRepository;
import com.quindioflix.repository.UsuarioRepository;
import com.quindioflix.repository.PagoRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/usuarios")
@RequiredArgsConstructor
public class UsuarioController {

    private final UsuarioRepository usuarioRepository;
    private final PerfilRepository perfilRepository;
    private final ReproduccionRepository reproduccionRepository;
    private final PagoRepository pagoRepository;

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
                        .plan(u.getPlan() != null ? u.getPlan().getNombrePlan() : null)
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
                .plan(usuario.getPlan() != null ? usuario.getPlan().getNombrePlan() : null)
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

    @PostMapping("/{id}/cambiar-plan")
    public ResponseEntity<Void> cambiarPlan(@PathVariable Long id,
                                            @RequestParam("nuevoPlanId") Long nuevoPlanId) {
        usuarioRepository.cambiarPlanSuscripcion(id, nuevoPlanId);
        return ResponseEntity.noContent().build();
    }
}

