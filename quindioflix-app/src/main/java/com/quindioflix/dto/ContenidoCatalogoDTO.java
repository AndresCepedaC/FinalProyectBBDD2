package com.quindioflix.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class ContenidoCatalogoDTO {
    private Long id;
    private String titulo;
    private String sinopsis;
    private String clasificacionEdad;
    private String nombreCategoria;
    private String urlPortada;
}
