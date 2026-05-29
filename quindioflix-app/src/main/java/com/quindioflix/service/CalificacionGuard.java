package com.quindioflix.service;

import com.quindioflix.h2.H2Triggers;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

import javax.sql.DataSource;
import java.sql.SQLException;

/**
 * En perfil demo (H2) aplica la misma regla que trg_validar_calificacion en Oracle.
 */
@Component
@Profile("demo")
@RequiredArgsConstructor
public class CalificacionGuard {

    private final DataSource dataSource;

    public void validarAntesDeCalificar(Long idPerfil, Long idContenido) {
        try (var conn = dataSource.getConnection()) {
            H2Triggers.validarCalificacion(conn, idPerfil, idContenido);
        } catch (SQLException e) {
            throw new RuntimeException(e.getMessage(), e);
        }
    }
}
