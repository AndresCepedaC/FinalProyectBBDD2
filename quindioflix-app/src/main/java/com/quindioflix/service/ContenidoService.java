package com.quindioflix.service;

import com.quindioflix.model.Contenido;
import com.quindioflix.repository.ContenidoRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class ContenidoService {

    private final ContenidoRepository contenidoRepository;

    @Transactional(readOnly = true)
    public Page<Contenido> obtenerCatalogoPaginado(Pageable pageable) {
        return contenidoRepository.findAll(pageable);
    }

    @Transactional(readOnly = true)
    public Contenido obtenerDetalleContenido(Long id) {
        return contenidoRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Contenido no encontrado con ID: " + id));
    }
}
