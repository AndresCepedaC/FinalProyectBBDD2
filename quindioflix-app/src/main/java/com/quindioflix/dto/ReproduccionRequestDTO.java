package com.quindioflix.dto;

import lombok.Data;

@Data
public class ReproduccionRequestDTO {
    private Long idPerfil;
    private Long idContenido;
    private String dispositivo;
    private Double porcentajeAvance;
}
