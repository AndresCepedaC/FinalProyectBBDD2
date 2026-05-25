package com.quindioflix.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Entity
@Table(name = "HISTORIAL_PLANES")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class HistorialPlan {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "seq_historial_planes")
    @SequenceGenerator(name = "seq_historial_planes", sequenceName = "SEQ_HISTORIAL_PLANES", allocationSize = 1)
    @Column(name = "id_historial")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_usuario", nullable = false)
    private Usuario usuario;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_plan_anterior", nullable = false)
    private Plan planAnterior;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_plan_nuevo", nullable = false)
    private Plan planNuevo;

    @Column(name = "fecha_cambio")
    private LocalDate fechaCambio;

    @Column(name = "motivo", length = 200)
    private String motivo;
}
