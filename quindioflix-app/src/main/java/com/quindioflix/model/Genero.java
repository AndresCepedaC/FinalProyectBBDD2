package com.quindioflix.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "GENEROS")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Genero {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "seq_generos")
    @SequenceGenerator(name = "seq_generos", sequenceName = "SEQ_GENEROS", allocationSize = 1)
    @Column(name = "id_genero")
    private Long id;

    @Column(name = "nombre_genero", unique = true, nullable = false, length = 50)
    private String nombreGenero;
}
