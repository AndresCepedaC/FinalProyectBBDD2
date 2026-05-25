package com.quindioflix.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "DEPARTAMENTOS")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Departamento {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "seq_departamentos")
    @SequenceGenerator(name = "seq_departamentos", sequenceName = "SEQ_DEPARTAMENTOS", allocationSize = 1)
    @Column(name = "id_departamento")
    private Long id;

    @Column(name = "nombre_departamento", unique = true, nullable = false, length = 50)
    private String nombreDepartamento;

    @Column(name = "id_empleado_jefe")
    private Long idEmpleadoJefe;
}
