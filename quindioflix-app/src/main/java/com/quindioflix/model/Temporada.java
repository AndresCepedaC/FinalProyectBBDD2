package com.quindioflix.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "TEMPORADAS", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"id_contenido", "numero_temporada"})
})
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Temporada {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "seq_temporadas")
    @SequenceGenerator(name = "seq_temporadas", sequenceName = "SEQ_TEMPORADAS", allocationSize = 1)
    @Column(name = "id_temporada")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_contenido", nullable = false)
    private Contenido contenido;

    @Column(name = "numero_temporada", nullable = false)
    private Integer numeroTemporada;
}
