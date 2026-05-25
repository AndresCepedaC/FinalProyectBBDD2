package com.quindioflix.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "EPISODIOS", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"id_temporada", "numero_episodio"})
})
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Episodio {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "seq_episodios")
    @SequenceGenerator(name = "seq_episodios", sequenceName = "SEQ_EPISODIOS", allocationSize = 1)
    @Column(name = "id_episodio")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_temporada", nullable = false)
    private Temporada temporada;

    @Column(name = "numero_episodio", nullable = false)
    private Integer numeroEpisodio;

    @Column(name = "titulo_episodio", length = 150)
    private String tituloEpisodio;

    @Column(name = "duracion_minutos", nullable = false)
    private Integer duracionMinutos;
}
