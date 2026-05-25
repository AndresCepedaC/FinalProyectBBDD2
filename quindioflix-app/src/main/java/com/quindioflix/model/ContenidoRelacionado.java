package com.quindioflix.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.io.Serializable;

@Entity
@Table(name = "CONTENIDO_RELACIONADO")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ContenidoRelacionado {

    @EmbeddedId
    private ContenidoRelacionadoId id;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("idContenidoOrigen")
    @JoinColumn(name = "id_contenido_origen")
    private Contenido origen;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("idContenidoDestino")
    @JoinColumn(name = "id_contenido_destino")
    private Contenido destino;

    @Column(name = "tipo_relacion", nullable = false, length = 50)
    private String tipoRelacion;
    
    @Embeddable
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ContenidoRelacionadoId implements Serializable {
        private Long idContenidoOrigen;
        private Long idContenidoDestino;
    }
}
