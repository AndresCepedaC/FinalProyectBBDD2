package com.quindioflix.dto;

import lombok.Data;

@Data
public class CalificacionRequestDTO {
    private Long idPerfil;
    private Long idContenido;
    private Integer estrellas;
    private String resena;
}
