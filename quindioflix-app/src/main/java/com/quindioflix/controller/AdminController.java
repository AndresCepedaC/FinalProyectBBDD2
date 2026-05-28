package com.quindioflix.controller;

import com.quindioflix.dto.ClienteAdminDTO;
import com.quindioflix.model.Ciudad;
import com.quindioflix.model.Usuario;
import com.quindioflix.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
public class AdminController {

    private final UsuarioRepository usuarioRepository;
    private final PerfilRepository perfilRepository;
    private final CiudadRepository ciudadRepository;
    private final ContenidoRepository contenidoRepository;
    private final TemporadaRepository temporadaRepository;
    private final EpisodioRepository episodioRepository;
    private final ReproduccionRepository reproduccionRepository;
    private final CalificacionRepository calificacionRepository;
    private final PagoRepository pagoRepository;
    private final FavoritoRepository favoritoRepository;
    private final PlanRepository planRepository;
    private final CategoriaRepository categoriaRepository;
    private final GeneroRepository generoRepository;

    @GetMapping("/clientes")
    public List<ClienteAdminDTO> listarClientes() {
        Map<Long, String> ciudades = ciudadRepository.findAll().stream()
                .collect(Collectors.toMap(Ciudad::getId, Ciudad::getNombreCiudad));

        return usuarioRepository.findAllWithPlan().stream()
                .map(u -> toDto(u, ciudades))
                .toList();
    }

    @GetMapping("/estadisticas-datos")
    public Map<String, Object> estadisticasDatos() {
        Map<String, Long> conteos = new LinkedHashMap<>();
        conteos.put("planes", planRepository.count());
        conteos.put("usuarios", usuarioRepository.count());
        conteos.put("perfiles", perfilRepository.count());
        conteos.put("categorias", categoriaRepository.count());
        conteos.put("generos", generoRepository.count());
        conteos.put("contenido", contenidoRepository.count());
        conteos.put("temporadas", temporadaRepository.count());
        conteos.put("episodios", episodioRepository.count());
        conteos.put("reproducciones", reproduccionRepository.count());
        conteos.put("calificaciones", calificacionRepository.count());
        conteos.put("pagos", pagoRepository.count());
        conteos.put("favoritos", favoritoRepository.count());

        Map<String, Long> minimos = new LinkedHashMap<>();
        minimos.put("planes", 3L);
        minimos.put("usuarios", 30L);
        minimos.put("perfiles", 50L);
        minimos.put("categorias", 5L);
        minimos.put("generos", 8L);
        minimos.put("contenido", 40L);
        minimos.put("temporadas", 15L);
        minimos.put("episodios", 50L);
        minimos.put("reproducciones", 200L);
        minimos.put("calificaciones", 60L);
        minimos.put("pagos", 80L);
        minimos.put("favoritos", 40L);

        boolean cumple = minimos.entrySet().stream()
                .allMatch(e -> conteos.getOrDefault(e.getKey(), 0L) >= e.getValue());

        return Map.of("conteos", conteos, "minimos", minimos, "cumpleRequisitos", cumple);
    }

    private ClienteAdminDTO toDto(Usuario u, Map<Long, String> ciudades) {
        int perfiles = perfilRepository.countByUsuario_Id(u.getId());
        return ClienteAdminDTO.builder()
                .id(u.getId())
                .nombreCompleto(u.getNombreCompleto())
                .email(u.getEmail())
                .plan(u.getPlan() != null ? u.getPlan().getNombrePlan() : "—")
                .idPlan(u.getPlan() != null ? u.getPlan().getId() : null)
                .ciudad(ciudades.getOrDefault(u.getIdCiudad(), "—"))
                .estadoCuenta(u.getEstadoCuenta())
                .cantidadPerfiles(perfiles)
                .build();
    }
}
