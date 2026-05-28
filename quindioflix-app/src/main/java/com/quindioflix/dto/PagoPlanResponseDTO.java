package com.quindioflix.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class PagoPlanResponseDTO {
    private Long idPago;
    private String estadoPago;
    private Double monto;
    private String planAnterior;
    private String planNuevo;
    private String mensaje;
    private String referenciaTransaccion;
}
