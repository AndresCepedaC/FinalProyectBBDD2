package com.quindioflix.service;

import com.quindioflix.model.Plan;
import com.quindioflix.model.Usuario;
import com.quindioflix.repository.UsuarioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;

@Service
@RequiredArgsConstructor
public class UsuarioService {

    private final UsuarioRepository usuarioRepository;

    @Transactional
    public Usuario registrarUsuario(Usuario usuario, Long idPlan) {
        if (usuarioRepository.findByEmail(usuario.getEmail()).isPresent()) {
            throw new RuntimeException("El email ya esta registrado.");
        }
        
        Plan plan = new Plan();
        plan.setId(idPlan);
        usuario.setPlan(plan);
        usuario.setFechaRegistro(LocalDate.now());
        usuario.setEstadoCuenta("ACTIVO");
        
        return usuarioRepository.save(usuario);
    }
}
