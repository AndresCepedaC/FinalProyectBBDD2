package com.quindioflix.repository;

import com.quindioflix.model.Reproduccion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ReproduccionRepository extends JpaRepository<Reproduccion, Long> {
    long countByPerfilUsuarioId(Long usuarioId);
}

