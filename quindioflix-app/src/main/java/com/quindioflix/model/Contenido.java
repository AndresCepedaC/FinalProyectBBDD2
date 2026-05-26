package com.quindioflix.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.quindioflix.model.base.BaseEntity;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

import java.util.HashSet;
import java.util.Set;

@EqualsAndHashCode(callSuper = true)
@Entity
@Table(name = "CONTENIDO")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Contenido extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "seq_contenido")
    @SequenceGenerator(name = "seq_contenido", sequenceName = "SEQ_CONTENIDO", allocationSize = 1)
    @Column(name = "id_contenido")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_categoria", nullable = false)
    @JsonIgnore
    private Categoria categoria;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_empleado_publicador")
    @JsonIgnore
    private Empleado publicador;

    @Column(name = "titulo", nullable = false, length = 150)
    private String titulo;

    @Column(name = "ano_lanzamiento", nullable = false)
    private Integer anoLanzamiento;

    @Column(name = "duracion_minutos")
    private Integer duracionMinutos;

    @Column(name = "sinopsis", length = 2000)
    private String sinopsis;

    @Column(name = "clasificacion_edad", nullable = false, length = 10)
    private String clasificacionEdad;

    @Column(name = "es_original")
    private Integer esOriginal;

    @Column(name = "popularidad")
    private Integer popularidad;

    @Column(name = "estado", length = 20)
    private String estado;

    @ManyToMany
    @JoinTable(
        name = "CONTENIDO_GENERO",
        joinColumns = @JoinColumn(name = "id_contenido"),
        inverseJoinColumns = @JoinColumn(name = "id_genero")
    )
    @JsonIgnore
    @Builder.Default
    private Set<Genero> generos = new HashSet<>();
}
