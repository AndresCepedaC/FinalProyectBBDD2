package com.quindioflix.service;

import com.quindioflix.model.Plan;
import com.quindioflix.model.Usuario;
import com.quindioflix.repository.UsuarioRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class UsuarioServiceTest {

    @Mock
    private UsuarioRepository usuarioRepository;

    @InjectMocks
    private UsuarioService usuarioService;

    private Usuario usuarioPrueba;

    @BeforeEach
    void setUp() {
        usuarioPrueba = new Usuario();
        usuarioPrueba.setEmail("test@quindioflix.com");
        usuarioPrueba.setNombreCompleto("Usuario de Prueba");
    }

    @Test
    void registrarUsuario_Exito() {
        // Arrange
        when(usuarioRepository.findByEmail(anyString())).thenReturn(Optional.empty());
        when(usuarioRepository.save(any(Usuario.class))).thenReturn(usuarioPrueba);

        // Act
        Usuario resultado = usuarioService.registrarUsuario(usuarioPrueba, 1L);

        // Assert
        assertNotNull(resultado);
        assertEquals("ACTIVO", resultado.getEstadoCuenta());
        assertNotNull(resultado.getPlan());
        assertEquals(1L, resultado.getPlan().getId());
        verify(usuarioRepository, times(1)).save(any(Usuario.class));
    }

    @Test
    void registrarUsuario_EmailDuplicado_LanzaExcepcion() {
        // Arrange
        when(usuarioRepository.findByEmail("test@quindioflix.com")).thenReturn(Optional.of(usuarioPrueba));

        // Act & Assert
        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            usuarioService.registrarUsuario(usuarioPrueba, 1L);
        });

        assertEquals("El email ya esta registrado.", exception.getMessage());
        verify(usuarioRepository, never()).save(any(Usuario.class));
    }
}
