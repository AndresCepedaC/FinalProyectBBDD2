package com.quindioflix.model;

import com.quindioflix.model.base.BaseEntity;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

@EqualsAndHashCode(callSuper = true)
@Entity
@Table(name = "PERFILES")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Perfil extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "seq_perfiles")
    @SequenceGenerator(name = "seq_perfiles", sequenceName = "SEQ_PERFILES", allocationSize = 1)
    @Column(name = "id_perfil")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_usuario", nullable = false)
    private Usuario usuario;

    @Column(name = "nombre_perfil", nullable = false, length = 50)
    private String nombrePerfil;

    @Column(name = "avatar", length = 255)
    private String avatar;

    @Column(name = "tipo_perfil", nullable = false, length = 20)
    private String tipoPerfil;
}
