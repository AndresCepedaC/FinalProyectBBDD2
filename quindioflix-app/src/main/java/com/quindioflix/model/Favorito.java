package com.quindioflix.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Entity
@Table(name = "FAVORITOS", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"id_perfil", "id_contenido"})
})
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Favorito {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "seq_favoritos")
    @SequenceGenerator(name = "seq_favoritos", sequenceName = "SEQ_FAVORITOS", allocationSize = 1)
    @Column(name = "id_favorito")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_perfil", nullable = false)
    private Perfil perfil;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_contenido", nullable = false)
    private Contenido contenido;

    @Column(name = "fecha_agregado")
    private LocalDate fechaAgregado;
}
