package com.quindioflix.repository;

import com.quindioflix.model.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.jpa.repository.query.Procedure;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Repository
public interface UsuarioRepository extends JpaRepository<Usuario, Long> {
    
    Optional<Usuario> findByEmail(String email);

    // 1. Integracion avanzada: Llamar a un Procedimiento Almacenado de Oracle (PL/SQL)
    @Transactional
    @Procedure(procedureName = "SP_CAMBIAR_PLAN")
    void cambiarPlanSuscripcion(@Param("p_id_usuario") Long idUsuario, @Param("p_id_plan_nuevo") Long idPlanNuevo);

    // 2. Integracion avanzada: Consulta JPQL compleja con JOIN FETCH para evitar el problema N+1
    @Query("SELECT u FROM Usuario u JOIN FETCH u.plan p WHERE p.nombrePlan = :nombrePlan AND u.estadoCuenta = 'ACTIVO'")
    List<Usuario> findUsuariosActivosPorPlan(@Param("nombrePlan") String nombrePlan);
    
    // 3. Integracion avanzada: Consulta Nativa (Native Query) llamando a vistas de Oracle
    @Query(value = "SELECT * FROM USUARIOS WHERE estado_cuenta = 'SUSPENDIDO' AND TRUNC(SYSDATE - fecha_ultimo_pago) > 30", nativeQuery = true)
    List<Usuario> findUsuariosMorososNativo();
}
