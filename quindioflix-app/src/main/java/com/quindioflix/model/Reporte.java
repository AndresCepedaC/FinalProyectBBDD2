package com.quindioflix.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Entity
@Table(name = "REPORTES")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Reporte {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "seq_reportes")
    @SequenceGenerator(name = "seq_reportes", sequenceName = "SEQ_REPORTES", allocationSize = 1)
    @Column(name = "id_reporte")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_perfil", nullable = false)
    private Perfil perfil;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_contenido", nullable = false)
    private Contenido contenido;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_empleado_moderador")
    private Empleado moderador;

    @Column(name = "descripcion_reporte", nullable = false, length = 500)
    private String descripcionReporte;

    @Column(name = "estado_reporte", length = 20)
    private String estadoReporte;

    @Column(name = "resolucion_descripcion", length = 500)
    private String resolucionDescripcion;

    @Column(name = "fecha_reporte")
    private LocalDate fechaReporte;

    @Column(name = "fecha_resolucion")
    private LocalDate fechaResolucion;
}
