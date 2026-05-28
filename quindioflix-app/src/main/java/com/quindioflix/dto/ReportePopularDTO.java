package com.quindioflix.dto;

import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;

@Data
@Builder
public class ReportePopularDTO {
    private String titulo;
    private String categoria;
    private Long totalReproducciones;
    private BigDecimal calificacionPromedio;
}
