package com.quindioflix.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class CambiarPlanPagoDTO {
    @NotNull
    private Long nuevoPlanId;

    @NotBlank
    private String numeroTarjeta;

    @NotBlank
    private String nombreTitular;

    private String metodoPago = "TARJETA_CREDITO";
}
