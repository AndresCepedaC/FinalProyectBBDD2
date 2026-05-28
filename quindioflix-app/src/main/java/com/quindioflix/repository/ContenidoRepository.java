package com.quindioflix.repository;

import com.quindioflix.model.Contenido;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ContenidoRepository extends JpaRepository<Contenido, Long> {

    @Query(value = "SELECT c FROM Contenido c LEFT JOIN FETCH c.categoria",
           countQuery = "SELECT COUNT(c) FROM Contenido c")
    Page<Contenido> findAllWithCategoria(Pageable pageable);

    @Query("SELECT DISTINCT c FROM Contenido c LEFT JOIN FETCH c.categoria LEFT JOIN FETCH c.generos WHERE c.id = :id")
    Optional<Contenido> findByIdWithDetalles(Long id);
}

