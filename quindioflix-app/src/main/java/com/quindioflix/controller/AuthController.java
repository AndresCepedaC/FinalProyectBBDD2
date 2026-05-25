package com.quindioflix.controller;

import com.quindioflix.dto.RegistroUsuarioDTO;
import com.quindioflix.model.Usuario;
import com.quindioflix.service.UsuarioService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final UsuarioService usuarioService;
    private final PasswordEncoder passwordEncoder;

    @PostMapping("/register")
    public ResponseEntity<?> registrarUsuario(@Valid @RequestBody RegistroUsuarioDTO dto) {
        
        Usuario nuevoUsuario = new Usuario();
        nuevoUsuario.setNombreCompleto(dto.getNombreCompleto());
        nuevoUsuario.setEmail(dto.getEmail());
        nuevoUsuario.setTelefono(dto.getTelefono());
        nuevoUsuario.setFechaNacimiento(dto.getFechaNacimiento());
        nuevoUsuario.setIdCiudad(dto.getIdCiudad());
        
        // Encriptar la contrasena antes de guardar en Base de Datos
        nuevoUsuario.setContrasenaHash(passwordEncoder.encode(dto.getContrasena()));
        
        Usuario usuarioGuardado = usuarioService.registrarUsuario(nuevoUsuario, dto.getIdPlan());
        
        return new ResponseEntity<>(usuarioGuardado, HttpStatus.CREATED);
    }
}
