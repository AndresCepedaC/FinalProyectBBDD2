package com.quindioflix.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Entity
@Table(name = "CALIFICACIONES", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"id_perfil", "id_contenido"})
})
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Calificacion {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "seq_calificaciones")
    @SequenceGenerator(name = "seq_calificaciones", sequenceName = "SEQ_CALIFICACIONES", allocationSize = 1)
    @Column(name = "id_calificacion")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_perfil", nullable = false)
    private Perfil perfil;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_contenido", nullable = false)
    private Contenido contenido;

    @Column(name = "estrellas", nullable = false)
    private Integer estrellas;

    @Column(name = "resena", length = 1000)
    private String resena;

    @Column(name = "fecha_calificacion")
    private LocalDate fechaCalificacion;
}
