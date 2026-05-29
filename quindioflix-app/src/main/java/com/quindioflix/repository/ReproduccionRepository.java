package com.quindioflix.repository;

import com.quindioflix.model.Reproduccion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ReproduccionRepository extends JpaRepository<Reproduccion, Long> {
    long countByPerfilUsuarioId(Long usuarioId);

    @Query("SELECT MAX(r.porcentajeAvance) FROM Reproduccion r WHERE r.perfil.id = :idPerfil AND r.contenido.id = :idContenido")
    Optional<Double> findMaxAvanceByPerfilAndContenido(@Param("idPerfil") Long idPerfil, @Param("idContenido") Long idContenido);
}

