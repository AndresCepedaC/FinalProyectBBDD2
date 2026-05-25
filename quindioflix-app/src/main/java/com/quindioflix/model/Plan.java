package com.quindioflix.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "PLANES")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Plan {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "seq_planes")
    @SequenceGenerator(name = "seq_planes", sequenceName = "SEQ_PLANES", allocationSize = 1)
    @Column(name = "id_plan")
    private Long id;

    @Column(name = "nombre_plan", unique = true, nullable = false, length = 50)
    private String nombrePlan;

    @Column(name = "limite_pantallas", nullable = false)
    private Integer limitePantallas;

    @Column(name = "max_perfiles", nullable = false)
    private Integer maxPerfiles;

    @Column(name = "calidad", nullable = false, length = 10)
    private String calidad;

    @Column(name = "precio_mensual", nullable = false)
    private Double precioMensual;
}
