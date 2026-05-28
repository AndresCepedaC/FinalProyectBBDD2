package com.quindioflix.dto;

import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class ContenidoDetalleDTO {
    private Long id;
    private String titulo;
    private String sinopsis;
    private String nombreCategoria;
    private String clasificacionEdad;
    private Integer anoLanzamiento;
    private Integer duracionMinutos;
    private String duracionTexto;
    private String tipoContenido;
    private boolean esSerie;
    private Integer totalTemporadas;
    private Integer totalEpisodios;
    private List<TemporadaResumenDTO> temporadas;
    private List<String> generos;
    private Integer popularidad;
    private String estado;
    private boolean esOriginal;
    private String urlPortada;

    @Data
    @Builder
    public static class TemporadaResumenDTO {
        private Integer numeroTemporada;
        private Integer cantidadEpisodios;
    }
}
