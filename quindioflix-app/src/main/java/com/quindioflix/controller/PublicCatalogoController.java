package com.quindioflix.controller;

import com.quindioflix.model.Ciudad;
import com.quindioflix.model.Plan;
import com.quindioflix.repository.CiudadRepository;
import com.quindioflix.repository.PlanRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/public")
@RequiredArgsConstructor
public class PublicCatalogoController {

    private final PlanRepository planRepository;
    private final CiudadRepository ciudadRepository;

    @GetMapping("/planes")
    public List<Plan> listarPlanes() {
        return planRepository.findAll();
    }

    @GetMapping("/ciudades")
    public List<Ciudad> listarCiudades() {
        return ciudadRepository.findAll();
    }
}

