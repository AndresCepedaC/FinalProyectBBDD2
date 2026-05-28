package com.quindioflix.repository;

import com.quindioflix.model.Perfil;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface PerfilRepository extends JpaRepository<Perfil, Long> {
    int countByUsuario_Id(Long usuarioId);
}

