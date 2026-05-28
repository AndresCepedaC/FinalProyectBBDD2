package com.quindioflix.controller;

import com.quindioflix.dto.ReportePopularDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/reportes")
@RequiredArgsConstructor
public class ReportesController {

    private final JdbcTemplate jdbcTemplate;

    @GetMapping("/populares")
    public List<ReportePopularDTO> populares(@RequestParam(defaultValue = "20") int limit) {
        return contenidoPopular(limit);
    }

    @GetMapping("/contenido-popular")
    public List<ReportePopularDTO> contenidoPopular(@RequestParam(defaultValue = "10") int limit) {
        int safeLimit = Math.max(1, Math.min(limit, 100));
        // H2 no acepta LIMIT con parametro preparado; el limite se valida arriba
        String sql = """
            SELECT titulo, nombre_categoria, total_reproducciones, calificacion_promedio
            FROM MV_CONTENIDO_POPULAR
            ORDER BY total_reproducciones DESC, calificacion_promedio DESC
            FETCH FIRST %d ROWS ONLY
            """.formatted(safeLimit);
        return jdbcTemplate.query(sql, (rs, rowNum) -> ReportePopularDTO.builder()
                .titulo(rs.getString("titulo"))
                .categoria(rs.getString("nombre_categoria"))
                .totalReproducciones(rs.getLong("total_reproducciones"))
                .calificacionPromedio(rs.getBigDecimal("calificacion_promedio"))
                .build());
    }

    @GetMapping("/ingresos-mensuales")
    public List<Map<String, Object>> ingresosMensuales(@RequestParam(required = false) Integer anio,
                                                       @RequestParam(required = false) Integer mes) {
        String base = """
            SELECT nombre_ciudad, nombre_plan, anio, mes, total_ingresos, cantidad_pagos
            FROM MV_INGRESOS_MENSUALES
            """;

        if (anio != null && mes != null) {
            return jdbcTemplate.queryForList(base + " WHERE anio = ? AND mes = ? ORDER BY total_ingresos DESC", anio, mes);
        }
        if (anio != null) {
            return jdbcTemplate.queryForList(base + " WHERE anio = ? ORDER BY anio DESC, mes DESC, total_ingresos DESC", anio);
        }
        return jdbcTemplate.queryForList(base + " ORDER BY anio DESC, mes DESC, total_ingresos DESC");
    }
}
