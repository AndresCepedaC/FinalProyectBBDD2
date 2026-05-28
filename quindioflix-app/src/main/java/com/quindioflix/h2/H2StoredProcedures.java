package com.quindioflix.h2;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class H2StoredProcedures {

    public static void cambiarPlan(Connection conn, Long p_id_usuario, Long p_id_plan_nuevo) throws SQLException {
        Long planActual = null;
        int perfilesActuales = 0;
        
        try (PreparedStatement psUser = conn.prepareStatement("SELECT id_plan FROM USUARIOS WHERE id_usuario = ?")) {
            psUser.setLong(1, p_id_usuario);
            try (ResultSet rsUser = psUser.executeQuery()) {
                if (rsUser.next()) {
                    planActual = rsUser.getLong("id_plan");
                }
            }
        }
        
        if (planActual == null) {
            throw new SQLException("El usuario no existe.", "20001", -20001);
        }
        
        try (PreparedStatement psPerf = conn.prepareStatement("SELECT COUNT(*) FROM PERFILES WHERE id_usuario = ?")) {
            psPerf.setLong(1, p_id_usuario);
            try (ResultSet rsPerf = psPerf.executeQuery()) {
                if (rsPerf.next()) {
                    perfilesActuales = rsPerf.getInt(1);
                }
            }
        }
        
        int maxPerfilesNuevo = 0;
        try (PreparedStatement psPlan = conn.prepareStatement("SELECT max_perfiles FROM PLANES WHERE id_plan = ?")) {
            psPlan.setLong(1, p_id_plan_nuevo);
            try (ResultSet rsPlan = psPlan.executeQuery()) {
                if (rsPlan.next()) {
                    maxPerfilesNuevo = rsPlan.getInt("max_perfiles");
                }
            }
        }
        
        if (perfilesActuales > maxPerfilesNuevo) {
            throw new SQLException("No se puede cambiar al plan. El usuario tiene " + perfilesActuales + " perfiles, y el nuevo plan permite maximo " + maxPerfilesNuevo, "20002", -20002);
        }
        
        try (PreparedStatement psUpd = conn.prepareStatement("UPDATE USUARIOS SET id_plan = ? WHERE id_usuario = ?")) {
            psUpd.setLong(1, p_id_plan_nuevo);
            psUpd.setLong(2, p_id_usuario);
            psUpd.executeUpdate();
        }
        
        try (PreparedStatement psHist = conn.prepareStatement("INSERT INTO HISTORIAL_PLANES (id_historial, id_usuario, id_plan_anterior, id_plan_nuevo, fecha_cambio, motivo) VALUES (NEXT VALUE FOR SEQ_HISTORIAL_PLANES, ?, ?, ?, CURRENT_DATE, 'Cambio de plan (SP_CAMBIAR_PLAN)')")) {
            psHist.setLong(1, p_id_usuario);
            psHist.setLong(2, planActual);
            psHist.setLong(3, p_id_plan_nuevo);
            psHist.executeUpdate();
        }
    }
}
