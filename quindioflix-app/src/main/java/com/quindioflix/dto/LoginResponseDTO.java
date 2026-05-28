package com.quindioflix.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class LoginResponseDTO {
    private String token;
    private Long idUsuario;
    private String nombre;
    private String email;
    private String rol; // 'ADMIN' o 'USER'
}
