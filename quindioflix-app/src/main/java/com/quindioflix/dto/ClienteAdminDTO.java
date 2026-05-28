package com.quindioflix.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class ClienteAdminDTO {
    private Long id;
    private String nombreCompleto;
    private String email;
    private String plan;
    private Long idPlan;
    private String ciudad;
    private String estadoCuenta;
    private int cantidadPerfiles;
}
