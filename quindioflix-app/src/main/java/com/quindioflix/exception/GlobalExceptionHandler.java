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
        Map<String, Object> body = new HashMap<>();
        body.put("timestamp", LocalDateTime.now());
        body.put("message", ex.getMessage());
        body.put("status", HttpStatus.BAD_REQUEST.value());

        return new ResponseEntity<>(body, HttpStatus.BAD_REQUEST);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, Object>> handleGeneralException(Exception ex) {
        Map<String, Object> body = new HashMap<>();
        body.put("timestamp", LocalDateTime.now());
        
        // Manejo Avanzado: Capturar excepciones personalizadas lanzadas por los TRIGGERS de Oracle (ORA-2000X)
        if (ex.getMessage() != null && ex.getMessage().contains("ORA-2000")) {
            body.put("message", "Regla de negocio de la Base de Datos violada.");
            body.put("database_error", ex.getMessage().split("\n")[0]); // Extrae solo la linea del error ORA
            body.put("status", HttpStatus.CONFLICT.value());
            return new ResponseEntity<>(body, HttpStatus.CONFLICT);
        }

        body.put("message", "Ha ocurrido un error interno en el servidor.");
        body.put("error", ex.getMessage());
        body.put("status", HttpStatus.INTERNAL_SERVER_ERROR.value());

        return new ResponseEntity<>(body, HttpStatus.INTERNAL_SERVER_ERROR);
    }
}
