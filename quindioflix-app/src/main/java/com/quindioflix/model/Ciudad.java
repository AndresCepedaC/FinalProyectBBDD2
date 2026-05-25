package com.quindioflix.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "CIUDADES")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Ciudad {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "seq_ciudades")
    @SequenceGenerator(name = "seq_ciudades", sequenceName = "SEQ_CIUDADES", allocationSize = 1)
    @Column(name = "id_ciudad")
    private Long id;

    @Column(name = "nombre_ciudad", unique = true, nullable = false, length = 100)
    private String nombreCiudad;
}
