package com.quindioflix.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UsuarioPublicoDTO {
    private Long id;
    private String nombreCompleto;
    private String email;
    private Long idCiudad;
    private String estadoCuenta;
    private String plan;
}

