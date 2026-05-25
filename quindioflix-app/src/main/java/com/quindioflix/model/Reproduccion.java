package com.quindioflix.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "REPRODUCCIONES")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Reproduccion {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "seq_reproducciones")
    @SequenceGenerator(name = "seq_reproducciones", sequenceName = "SEQ_REPRODUCCIONES", allocationSize = 1)
    @Column(name = "id_reproduccion")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_perfil", nullable = false)
    private Perfil perfil;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_contenido", nullable = false)
    private Contenido contenido;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_episodio")
    private Episodio episodio;

    @Column(name = "fecha_hora_inicio", nullable = false)
    private LocalDateTime fechaHoraInicio;

    @Column(name = "fecha_hora_fin")
    private LocalDateTime fechaHoraFin;

    @Column(name = "dispositivo", nullable = false, length = 20)
    private String dispositivo;

    @Column(name = "porcentaje_avance")
    private Double porcentajeAvance;
}
