package com.quindioflix.h2;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Logica equivalente a trg_validar_calificacion (Oracle / H2).
 * En perfil demo se invoca desde {@link com.quindioflix.service.CalificacionGuard}.
 */
public final class H2Triggers {

    private H2Triggers() {
    }

    public static void validarCalificacion(Connection conn, long idPerfil, long idContenido) throws SQLException {
        int duracionTotal = 45;
        try (PreparedStatement psCont = conn.prepareStatement(
                "SELECT COALESCE(duracion_minutos, 45) FROM CONTENIDO WHERE id_contenido = ?")) {
            psCont.setLong(1, idContenido);
            try (ResultSet rs = psCont.executeQuery()) {
                if (rs.next()) {
                    duracionTotal = rs.getInt(1);
                } else {
                    throw new SQLException(
                            "Error: Debes ver al menos el 50% del contenido para poder calificarlo.",
                            "20005", -20005);
                }
            }
        }

        double minutosVistos = 0;
        try (PreparedStatement psRep = conn.prepareStatement("""
                SELECT COALESCE(MAX((r.porcentaje_avance / 100.0) * COALESCE(c.duracion_minutos, 45)), 0)
                FROM REPRODUCCIONES r
                INNER JOIN CONTENIDO c ON c.id_contenido = r.id_contenido
                WHERE r.id_perfil = ? AND r.id_contenido = ?
                """)) {
            psRep.setLong(1, idPerfil);
            psRep.setLong(2, idContenido);
            try (ResultSet rs = psRep.executeQuery()) {
                if (rs.next()) {
                    minutosVistos = rs.getDouble(1);
                }
            }
        }

        double minimoRequerido = duracionTotal * 0.5;
        if (minutosVistos < minimoRequerido) {
            throw new SQLException(
                    "Error: Debes ver al menos el 50% del contenido para poder calificarlo. " +
                            "Minutos vistos: " + String.format("%.1f", minutosVistos) +
                            " / requeridos: " + String.format("%.1f", minimoRequerido),
                    "20005", -20005);
        }
    }
}
