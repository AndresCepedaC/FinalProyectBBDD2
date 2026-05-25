package com.quindioflix.controller;

import com.quindioflix.model.Contenido;
import com.quindioflix.service.ContenidoService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/contenidos")
@RequiredArgsConstructor
public class ContenidoController {

    private final ContenidoService contenidoService;

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
}
