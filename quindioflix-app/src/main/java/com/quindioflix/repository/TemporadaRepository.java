package com.quindioflix.repository;

import com.quindioflix.model.Temporada;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TemporadaRepository extends JpaRepository<Temporada, Long> {
    List<Temporada> findByContenido_IdOrderByNumeroTemporadaAsc(Long contenidoId);
    long countByContenido_Id(Long contenidoId);
}

