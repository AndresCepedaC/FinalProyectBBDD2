package com.quindioflix.repository;

import com.quindioflix.model.Episodio;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface EpisodioRepository extends JpaRepository<Episodio, Long> {
    long countByTemporada_Contenido_Id(Long contenidoId);
    long countByTemporada_Id(Long temporadaId);
}

