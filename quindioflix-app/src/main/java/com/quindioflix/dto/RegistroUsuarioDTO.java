package com.quindioflix.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.time.LocalDate;

@Data
public class RegistroUsuarioDTO {

    @NotBlank(message = "El nombre es obligatorio")
    @Size(min = 3, max = 150, message = "El nombre debe tener entre 3 y 150 caracteres")
    private String nombreCompleto;

    @NotBlank(message = "El email es obligatorio")
    @Email(message = "Debe ser un email valido")
    private String email;

    @NotBlank(message = "La contrasena es obligatoria")
    @Size(min = 6, message = "La contrasena debe tener al menos 6 caracteres")
    private String contrasena;

    private String telefono;

    @NotNull(message = "La fecha de nacimiento es obligatoria")
    private LocalDate fechaNacimiento;

    @NotNull(message = "Debe seleccionar una ciudad")
    private Long idCiudad;

    @NotNull(message = "Debe seleccionar un plan de suscripcion")
    private Long idPlan;
}
