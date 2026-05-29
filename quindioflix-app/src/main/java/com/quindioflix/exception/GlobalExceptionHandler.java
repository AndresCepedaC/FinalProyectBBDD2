package com.quindioflix.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@ControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<Map<String, Object>> handleRuntimeException(RuntimeException ex) {
        ex.printStackTrace(); // Log stack trace to help diagnose stored procedure failures
        Map<String, Object> body = new HashMap<>();
        body.put("timestamp", LocalDateTime.now());
        body.put("message", ex.getMessage());
        body.put("status", HttpStatus.BAD_REQUEST.value());

        return new ResponseEntity<>(body, HttpStatus.BAD_REQUEST);
    }

    @ExceptionHandler({java.sql.SQLException.class, org.springframework.dao.DataIntegrityViolationException.class})
    public ResponseEntity<Map<String, String>> handleDatabaseExceptions(Exception ex) {
        String fullMessage = ex.getMessage();
        String cleanMessage = "Error en la base de datos.";
        
        if (fullMessage != null && fullMessage.contains("ORA-2000")) {
            // Extraer el texto limpio del trigger (ej. ORA-20001: Límite superado)
            int startIndex = fullMessage.indexOf("ORA-2000");
            int colonIndex = fullMessage.indexOf(":", startIndex);
            int newLineIndex = fullMessage.indexOf("\n", startIndex);
            
            if (colonIndex != -1) {
                if (newLineIndex != -1) {
                    cleanMessage = fullMessage.substring(colonIndex + 1, newLineIndex).trim();
                } else {
                    cleanMessage = fullMessage.substring(colonIndex + 1).trim();
                }
            }
        } else if (fullMessage != null) {
            // H2 stored procedure errors: extraer mensaje antes de "; SQL statement:"
            int sqlStmtIdx = fullMessage.indexOf("; SQL statement:");
            if (sqlStmtIdx != -1) {
                cleanMessage = fullMessage.substring(0, sqlStmtIdx).trim();
            }
            // También limpiar causas anidadas de Hibernate
            Throwable cause = ex.getCause();
            while (cause != null) {
                String causeMsg = cause.getMessage();
                if (causeMsg != null) {
                    int idx = causeMsg.indexOf("; SQL statement:");
                    if (idx != -1) {
                        cleanMessage = causeMsg.substring(0, idx).trim();
                        break;
                    }
                    // Último recurso: mensaje plano de SQLException
                    if (cause instanceof java.sql.SQLException) {
                        cleanMessage = causeMsg.contains("; SQL") 
                            ? causeMsg.substring(0, causeMsg.indexOf("; SQL")).trim() 
                            : causeMsg;
                        break;
                    }
                }
                cause = cause.getCause();
            }
        }
        
        Map<String, String> body = new HashMap<>();
        body.put("error", cleanMessage);
        body.put("message", cleanMessage);
        
        return new ResponseEntity<>(body, HttpStatus.CONFLICT);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, Object>> handleGeneralException(Exception ex) {
        Map<String, Object> body = new HashMap<>();
        body.put("timestamp", LocalDateTime.now());
        body.put("message", "Ha ocurrido un error interno en el servidor.");
        body.put("error", ex.getMessage());
        body.put("status", HttpStatus.INTERNAL_SERVER_ERROR.value());

        return new ResponseEntity<>(body, HttpStatus.INTERNAL_SERVER_ERROR);
    }
}
