package com.quindioflix.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Entity
@Table(name = "EMPLEADOS")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Empleado {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "seq_empleados")
    @SequenceGenerator(name = "seq_empleados", sequenceName = "SEQ_EMPLEADOS", allocationSize = 1)
    @Column(name = "id_empleado")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_departamento", nullable = false)
    private Departamento departamento;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_supervisor")
    private Empleado supervisor;

    @Column(name = "nombre_empleado", nullable = false, length = 100)
    private String nombreEmpleado;

    @Column(name = "email_empleado", unique = true, length = 100)
    private String emailEmpleado;

    @Column(name = "rol_empleado", nullable = false, length = 60)
    private String rolEmpleado;

    @Column(name = "fecha_contratacion")
    private LocalDate fechaContratacion;
}
