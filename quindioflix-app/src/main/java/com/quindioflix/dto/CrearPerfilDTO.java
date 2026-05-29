package com.quindioflix.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CrearPerfilDTO {

    @NotBlank(message = "El nombre del perfil es obligatorio")
    private String nombre;

    @NotBlank(message = "El tipo de perfil es obligatorio (INFANTIL o ADULTO)")
    private String tipo;

}
