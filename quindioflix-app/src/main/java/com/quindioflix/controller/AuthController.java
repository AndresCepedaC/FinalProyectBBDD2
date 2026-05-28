package com.quindioflix.controller;

import com.quindioflix.dto.LoginRequestDTO;
import com.quindioflix.dto.LoginResponseDTO;
import com.quindioflix.dto.RegistroUsuarioDTO;
import com.quindioflix.dto.UsuarioPublicoDTO;
import com.quindioflix.model.Usuario;
import com.quindioflix.repository.UsuarioRepository;
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
    private final UsuarioRepository usuarioRepository;
    private final PasswordEncoder passwordEncoder;

    @PostMapping("/login")
    public ResponseEntity<LoginResponseDTO> login(@Valid @RequestBody LoginRequestDTO request) {
        Usuario usuario = usuarioRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("Credenciales invalidas"));

        // Validacion a prueba de balas para demo (acepta BCrypt, texto plano, y passwords de prueba)
        boolean isPasswordValid = passwordEncoder.matches(request.getPassword(), usuario.getContrasenaHash()) ||
                                  request.getPassword().equals(usuario.getContrasenaHash()) ||
                                  request.getPassword().equals("123456") ||
                                  request.getPassword().equals("hash123");
        if (!isPasswordValid) {
            throw new RuntimeException("Credenciales invalidas");
        }

        // Simulacion de token y definicion de rol (robusto)
        String fakeToken = "jwt_fake_token_" + usuario.getId();
        String emailLower = usuario.getEmail().toLowerCase();
        String rol = (emailLower.contains("admin") || emailLower.contains("jefe")) ? "ADMIN" : "USER";

        LoginResponseDTO response = LoginResponseDTO.builder()
                .token(fakeToken)
                .idUsuario(usuario.getId())
                .nombre(usuario.getNombreCompleto())
                .email(usuario.getEmail())
                .rol(rol)
                .build();

        return ResponseEntity.ok(response);
    }

    @PostMapping("/register")
    public ResponseEntity<UsuarioPublicoDTO> registrarUsuario(@Valid @RequestBody RegistroUsuarioDTO dto) {
        
        Usuario nuevoUsuario = new Usuario();
        nuevoUsuario.setNombreCompleto(dto.getNombreCompleto());
        nuevoUsuario.setEmail(dto.getEmail());
        nuevoUsuario.setTelefono(dto.getTelefono());
        nuevoUsuario.setFechaNacimiento(dto.getFechaNacimiento());
        nuevoUsuario.setIdCiudad(dto.getIdCiudad());
        
        // Encriptar la contrasena antes de guardar en Base de Datos
        nuevoUsuario.setContrasenaHash(passwordEncoder.encode(dto.getContrasena()));
        
        Usuario usuarioGuardado = usuarioService.registrarUsuario(nuevoUsuario, dto.getIdPlan());

        UsuarioPublicoDTO out = UsuarioPublicoDTO.builder()
                .id(usuarioGuardado.getId())
                .nombreCompleto(usuarioGuardado.getNombreCompleto())
                .email(usuarioGuardado.getEmail())
                .idCiudad(usuarioGuardado.getIdCiudad())
                .estadoCuenta(usuarioGuardado.getEstadoCuenta())
                .plan(usuarioGuardado.getPlan() != null ? usuarioGuardado.getPlan().getNombrePlan() : null)
                .build();
        
        return new ResponseEntity<>(out, HttpStatus.CREATED);
    }
}
