package com.quindioflix.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "CATEGORIAS")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Categoria {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "seq_categorias")
    @SequenceGenerator(name = "seq_categorias", sequenceName = "SEQ_CATEGORIAS", allocationSize = 1)
    @Column(name = "id_categoria")
    private Long id;

    @Column(name = "nombre_categoria", unique = true, nullable = false, length = 50)
    private String nombreCategoria;
}
