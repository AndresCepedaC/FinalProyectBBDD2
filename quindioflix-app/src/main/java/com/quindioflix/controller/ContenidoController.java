package com.quindioflix.controller;

import com.quindioflix.dto.CalificacionRequestDTO;
import com.quindioflix.dto.ReproduccionRequestDTO;
import com.quindioflix.model.Calificacion;
import com.quindioflix.model.Contenido;
import com.quindioflix.model.Perfil;
import com.quindioflix.model.Reproduccion;
import com.quindioflix.repository.CalificacionRepository;
import com.quindioflix.repository.ContenidoRepository;
import com.quindioflix.repository.PerfilRepository;
import com.quindioflix.repository.ReproduccionRepository;
import com.quindioflix.service.ContenidoService;
import lombok.RequiredArgsConstructor;
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

    @GetMapping
    public ResponseEntity<Page<Contenido>> obtenerCatalogo(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "popularidad") String sortBy) {
        
        PageRequest pageRequest = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, sortBy));
        Page<Contenido> catalogo = contenidoService.obtenerCatalogoPaginado(pageRequest);
        return ResponseEntity.ok(catalogo);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Contenido> obtenerDetalle(@PathVariable Long id) {
        Contenido contenido = contenidoService.obtenerDetalleContenido(id);
        return ResponseEntity.ok(contenido);
    }

    @PostMapping("/reproducir")
    public ResponseEntity<Void> simularReproduccion(@RequestBody ReproduccionRequestDTO dto) {
        Perfil perfil = perfilRepository.findById(dto.getIdPerfil())
                .orElseThrow(() -> new RuntimeException("Perfil no encontrado"));
        Contenido contenido = contenidoRepository.findById(dto.getIdContenido())
                .orElseThrow(() -> new RuntimeException("Contenido no encontrado"));

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
