package com.quindioflix.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Entity
@Table(name = "DESCUENTOS_REFERIDOS")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DescuentoReferido {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "seq_descuentos_referidos")
    @SequenceGenerator(name = "seq_descuentos_referidos", sequenceName = "SEQ_DESCUENTOS_REFERIDOS", allocationSize = 1)
    @Column(name = "id_descuento")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_usuario_referidor", nullable = false)
    private Usuario referidor;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_usuario_referido", nullable = false)
    private Usuario referido;

    @Column(name = "porcentaje_descuento")
    private Double porcentajeDescuento;

    @Column(name = "estado", length = 20)
    private String estado;

    @Column(name = "fecha_aplicacion")
    private LocalDate fechaAplicacion;
}
