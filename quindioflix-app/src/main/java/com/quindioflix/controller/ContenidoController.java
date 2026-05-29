package com.quindioflix.controller;

import com.quindioflix.dto.CalificacionRequestDTO;
import com.quindioflix.dto.ContenidoCatalogoDTO;
import com.quindioflix.dto.ContenidoDetalleDTO;
import com.quindioflix.dto.ReproduccionRequestDTO;
import com.quindioflix.model.Calificacion;
import com.quindioflix.model.Contenido;
import com.quindioflix.model.Perfil;
import com.quindioflix.model.Reproduccion;
import com.quindioflix.repository.CalificacionRepository;
import com.quindioflix.repository.ContenidoRepository;
import com.quindioflix.repository.PerfilRepository;
import com.quindioflix.repository.ReproduccionRepository;
import com.quindioflix.service.CalificacionGuard;
import com.quindioflix.service.ContenidoService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;

@RestController
@RequestMapping("/api/contenidos")
@RequiredArgsConstructor
public class ContenidoController {

    private final ContenidoService contenidoService;
    private final ReproduccionRepository reproduccionRepository;
    private final CalificacionRepository calificacionRepository;
    private final PerfilRepository perfilRepository;
    private final ContenidoRepository contenidoRepository;
    private final ObjectProvider<CalificacionGuard> calificacionGuard;

    @GetMapping
    public ResponseEntity<Page<ContenidoCatalogoDTO>> obtenerCatalogo(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "popularidad") String sortBy) {
        
        PageRequest pageRequest = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, sortBy));
        Page<ContenidoCatalogoDTO> catalogo = contenidoService.obtenerCatalogoPaginado(pageRequest);
        return ResponseEntity.ok(catalogo);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ContenidoDetalleDTO> obtenerDetalle(@PathVariable Long id,
                                                               @RequestParam(required = false) Long idPerfil) {
        if (idPerfil != null) {
            Perfil perfil = perfilRepository.findById(idPerfil)
                    .orElseThrow(() -> new RuntimeException("Perfil no encontrado"));
            String estadoCuenta = perfil.getUsuario().getEstadoCuenta();
            if (!"ACTIVO".equals(estadoCuenta)) {
                if (estadoCuenta == null || estadoCuenta.isEmpty() || "SUSPENDIDO".equals(estadoCuenta)) {
                    throw new RuntimeException("Tu suscripción no está activa. No puedes ver contenido en este momento.");
                }
                throw new RuntimeException("Tu cuenta se encuentra en estado: " + estadoCuenta + ". No puedes ver contenido en este momento.");
            }
            if (perfil.getUsuario().getPlan() == null) {
                throw new RuntimeException("No tienes una suscripción activa. Por favor suscríbete a un plan para ver contenido.");
            }
        }
        return ResponseEntity.ok(contenidoService.obtenerDetalleContenido(id));
    }

    @PostMapping("/reproducir")
    public ResponseEntity<Void> simularReproduccion(@RequestBody ReproduccionRequestDTO dto) {
        Perfil perfil = perfilRepository.findById(dto.getIdPerfil())
                .orElseThrow(() -> new RuntimeException("Perfil no encontrado"));
        Contenido contenido = contenidoRepository.findById(dto.getIdContenido())
                .orElseThrow(() -> new RuntimeException("Contenido no encontrado"));

        if (!"ACTIVO".equals(perfil.getUsuario().getEstadoCuenta())) {
            throw new RuntimeException("No se puede reproducir contenido. La cuenta se encuentra en estado: " + perfil.getUsuario().getEstadoCuenta());
        }

        Reproduccion rep = Reproduccion.builder()
                .perfil(perfil)
                .contenido(contenido)
                .fechaHoraInicio(LocalDateTime.now())
                .fechaHoraFin(LocalDateTime.now().plusMinutes(120))
                .dispositivo(dto.getDispositivo() != null ? dto.getDispositivo() : "WEB")
                .porcentajeAvance(dto.getPorcentajeAvance())
                .build();
        
        reproduccionRepository.save(rep);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/calificar")
    public ResponseEntity<Void> simularCalificacion(@RequestBody CalificacionRequestDTO dto) {
        Perfil perfil = perfilRepository.findById(dto.getIdPerfil())
                .orElseThrow(() -> new RuntimeException("Perfil no encontrado"));
        Contenido contenido = contenidoRepository.findById(dto.getIdContenido())
                .orElseThrow(() -> new RuntimeException("Contenido no encontrado"));

        // Oracle: trg_validar_calificacion en BD. Demo: CalificacionGuard (misma regla con JOIN).
        calificacionGuard.ifAvailable(g -> g.validarAntesDeCalificar(dto.getIdPerfil(), dto.getIdContenido()));

        Calificacion cal = Calificacion.builder()
                .perfil(perfil)
                .contenido(contenido)
                .estrellas(dto.getEstrellas())
                .resena(dto.getResena())
                .fechaCalificacion(LocalDate.now())
                .build();
        
        calificacionRepository.save(cal);
        return ResponseEntity.ok().build();
    }
}
