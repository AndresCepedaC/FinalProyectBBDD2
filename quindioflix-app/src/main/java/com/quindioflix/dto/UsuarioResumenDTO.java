package com.quindioflix.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UsuarioResumenDTO {

    private Long id;
    private String nombreCompleto;
    private String email;
    private String plan;
    private String ciudad;
    private String estadoCuenta;

    private List<PerfilDTO> perfiles;
    private Long totalReproducciones;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class PerfilDTO {
        private Long id;
        private String nombre;
        private String tipo;
    }
}

