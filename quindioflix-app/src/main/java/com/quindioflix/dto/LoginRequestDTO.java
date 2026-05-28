package com.quindioflix.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class LoginRequestDTO {
    @NotBlank(message = "El email es requerido")
    @Email(message = "Formato de email invalido")
    private String email;

    @NotBlank(message = "La contrasena es requerida")
    private String password;
}
