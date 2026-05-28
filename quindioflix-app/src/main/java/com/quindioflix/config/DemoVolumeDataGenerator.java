package com.quindioflix.config;

import com.quindioflix.model.*;
import com.quindioflix.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;

/**
 * Genera datos asimetricos para cumplir minimos del proyecto (ROLLUP/CUBE/PIVOT).
 */
@Slf4j
@Component
@Profile("demo")
@RequiredArgsConstructor
public class DemoVolumeDataGenerator {

    private static final String HASH_123456 = "$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy";
    private static final String[] DISPOSITIVOS = {"TV", "CELULAR", "TABLET", "COMPUTADOR", "WEB"};
    private static final String[] METODOS = {"TARJETA_CREDITO", "NEQUI", "PSE", "DAVIPLATA"};

    private final UsuarioRepository usuarioRepository;
    private final PerfilRepository perfilRepository;
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
    private final EmpleadoRepository empleadoRepository;

    @Transactional
    public void generateIfNeeded() {
        List<Contenido> catalogo;
        boolean completo = usuarioRepository.count() >= 30
                && contenidoRepository.count() >= 40
                && perfilRepository.count() >= 50
                && temporadaRepository.count() >= 15
                && episodioRepository.count() >= 50
                && reproduccionRepository.count() >= 200
                && calificacionRepository.count() >= 60
                && pagoRepository.count() >= 80
                && favoritoRepository.count() >= 40;

        if (!completo) {
            log.info("Generando volumen de datos demo (asimetrico)...");
            Empleado publicador = empleadoRepository.findById(1L)
                    .orElseThrow(() -> new IllegalStateException("Ejecute data-h2.sql antes del generador de volumen"));
            catalogo = ensureContenido(publicador);
            List<Usuario> usuariosLista = ensureUsuarios();
            List<Perfil> perfiles = ensurePerfiles(usuariosLista);
            List<Temporada> temporadas = ensureTemporadas(catalogo);
            ensureEpisodios(temporadas);
            ensureReproducciones(perfiles, catalogo, temporadas);
            ensureCalificaciones(perfiles, catalogo);
            ensurePagos(usuariosLista);
            ensureFavoritos(perfiles, catalogo);
            log.info("Volumen demo listo: {} usuarios, {} contenidos, {} perfiles, {} reproducciones",
                    usuarioRepository.count(), contenidoRepository.count(),
                    perfilRepository.count(), reproduccionRepository.count());
        } else {
            catalogo = contenidoRepository.findAll();
        }
        asignarGenerosSiFaltan(catalogo);
    }

    private List<Contenido> ensureContenido(Empleado publicador) {
        if (contenidoRepository.count() >= 40) {
            return contenidoRepository.findAll();
        }
        String[] titulos = {
                "El Ultimo Guardian", "Conexion Digital", "Cafe y Secretos", "Noches de Tango",
                "Biodiversidad Oculta", "Codigo Rojo", "La Herencia", "Vuelo 404",
                "Aventuras en el Cocora", "Voces del Conflicto", "Sombras del Pasado", "Startup Valley",
                "Rio Verde", "Memorias del Eje", "El Camino del Quindio", "Noche en Filandia",
                "Paisaje Sonoro", "Tech Andina", "Misterio en Salento", "Corazones de Acero",
                "Infancia en el Pueblo", "Leyendas del Nevado", "Futbol de Barrio", "Cocina de Origina",
                "Viaje Estelar", "Historias del Cable", "Podcast del Cafe T1", "Risas en la Montaña",
                "Documental Aves", "Thriller Nocturno", "Amor en Armenia", "Ciudad Escondida",
                "Mini Detectives", "Sabores del Pacifico", "Rock del Quindio", "Silencio Rojo",
                "Comedia Express", "Drama Familiar", "Animales Heroes", "Crónicas Urbanas"
        };
        String[] edades = {"+18", "+16", "+13", "TP", "+7", "+16", "+13", "TP"};
        List<Contenido> creados = new ArrayList<>();
        for (int i = 0; i < 40; i++) {
            long catId = (i % 5) + 1;
            Contenido c = Contenido.builder()
                    .categoria(categoriaRef(catId))
                    .publicador(publicador)
                    .titulo(titulos[i])
                    .anoLanzamiento(2020 + (i % 5))
                    .duracionMinutos(catId == 2 || catId == 5 ? null : 90 + (i % 50))
                    .sinopsis("Sinopsis de " + titulos[i] + " — produccion QuindioFlix.")
                    .clasificacionEdad(edades[i % edades.length])
                    .esOriginal(i % 3 == 0 ? 1 : 0)
                    .popularidad(60 + (i % 40))
                    .estado("ACTIVO")
                    .build();
            creados.add(contenidoRepository.save(c));
        }
        return creados;
    }

    private List<Usuario> ensureUsuarios() {
        if (usuarioRepository.count() >= 30) {
            return usuarioRepository.findAll();
        }
        ensureUsuarioDemo("andres@demo.com", "Andres Cepeda Demo", 3L, 1L, "ACTIVO");
        ensureUsuarioDemo("admin@demo.com", "Administrador QFlix", 3L, 1L, "ACTIVO");

        // Distribucion ASIMETRICA: mas Basicos en Armenia, mas Premium en Medellin, etc.
        long[][] planPorCiudad = {
                {1L, 1L, 1L, 2L, 2L, 3L},           // Armenia (1) — muchos Basicos
                {2L, 2L, 2L, 2L, 3L, 3L},           // Pereira (2)
                {1L, 2L, 3L, 3L, 3L, 3L},           // Manizales (3)
                {2L, 3L, 3L, 1L, 2L, 3L},           // Bogota (4)
                {3L, 3L, 3L, 2L, 1L, 2L}            // Medellin (5) — muchos Premium
        };
        long[] ciudades = {1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 2L, 2L, 2L, 2L, 2L, 2L, 3L, 3L, 3L, 3L, 3L,
                4L, 4L, 4L, 4L, 4L, 5L, 5L, 5L, 5L};

        List<Usuario> lista = new ArrayList<>(usuarioRepository.findAll());
        int n = lista.size();
        for (int i = n; i < 30; i++) {
            long ciudad = ciudades[i - 2];
            int idxCiudad = ciudad == 1 ? 0 : ciudad == 2 ? 1 : ciudad == 3 ? 2 : ciudad == 4 ? 3 : 4;
            long planId = planPorCiudad[idxCiudad][i % 6];
            String estado = (i % 11 == 0) ? "SUSPENDIDO" : "ACTIVO";
            Usuario u = Usuario.builder()
                    .plan(planRef(planId))
                    .idCiudad(ciudad)
                    .nombreCompleto("Cliente Demo " + (i + 1))
                    .email("cliente" + (i + 1) + "@demo.com")
                    .contrasenaHash(HASH_123456)
                    .telefono("300" + String.format("%07d", i))
                    .fechaNacimiento(LocalDate.of(1985, 1, 1).plusDays(i * 40L))
                    .fechaRegistro(LocalDate.of(2024, 1, 1).plusMonths(i % 12))
                    .estadoCuenta(estado)
                    .fechaUltimoPago(LocalDate.now().minusDays(i % 60))
                    .build();
            lista.add(usuarioRepository.save(u));
        }
        return lista;
    }

    private void ensureUsuarioDemo(String email, String nombre, long planId, long ciudadId, String estado) {
        if (usuarioRepository.findByEmail(email).isPresent()) {
            return;
        }
        Usuario u = Usuario.builder()
                .plan(planRef(planId))
                .idCiudad(ciudadId)
                .nombreCompleto(nombre)
                .email(email)
                .contrasenaHash(HASH_123456)
                .telefono("3000000000")
                .fechaNacimiento(LocalDate.of(1990, 1, 1))
                .fechaRegistro(LocalDate.of(2024, 1, 1))
                .estadoCuenta(estado)
                .fechaUltimoPago(LocalDate.now())
                .build();
        usuarioRepository.save(u);
    }

    private List<Perfil> ensurePerfiles(List<Usuario> usuarios) {
        if (perfilRepository.count() >= 50) {
            return perfilRepository.findAll();
        }
        List<Perfil> lista = new ArrayList<>(perfilRepository.findAll());
        Random rnd = new Random(42);
        for (Usuario u : usuarios) {
            long existentes = perfilRepository.countByUsuario_Id(u.getId());
            int objetivo = u.getEmail().equals("andres@demo.com") ? 2
                    : (u.getEmail().equals("admin@demo.com") ? 1 : 1 + rnd.nextInt(3));
            for (int p = (int) existentes; p < objetivo && lista.size() < 50; p++) {
                boolean infantil = u.getEmail().equals("andres@demo.com") && p == 1;
                String nombrePerfil = infantil ? "Hijo de Andres"
                        : (p == 0 ? u.getNombreCompleto().split(" ")[0] : u.getNombreCompleto().split(" ")[0] + " " + (p + 1));
                Perfil perfil = Perfil.builder()
                        .usuario(u)
                        .nombrePerfil(nombrePerfil)
                        .avatar("avatar.png")
                        .tipoPerfil(infantil ? "INFANTIL" : (p == 0 ? "ADULTO" : (rnd.nextBoolean() ? "ADULTO" : "INFANTIL")))
                        .build();
                lista.add(perfilRepository.save(perfil));
            }
        }
        while (lista.size() < 50 && !usuarios.isEmpty()) {
            Usuario u = usuarios.get(lista.size() % usuarios.size());
            Perfil extra = Perfil.builder()
                    .usuario(u)
                    .nombrePerfil("Extra " + lista.size())
                    .avatar("avatar.png")
                    .tipoPerfil("ADULTO")
                    .build();
            lista.add(perfilRepository.save(extra));
        }
        return lista;
    }

    private List<Temporada> ensureTemporadas(List<Contenido> catalogo) {
        if (temporadaRepository.count() >= 15) {
            return temporadaRepository.findAll();
        }
        List<Contenido> series = catalogo.stream()
                .filter(c -> c.getCategoria() != null
                        && (c.getCategoria().getId() == 2L || c.getCategoria().getId() == 5L))
                .toList();
        List<Temporada> temps = new ArrayList<>();
        int t = 0;
        for (Contenido c : series) {
            if (t >= 15) break;
            for (int num = 1; num <= 2 && t < 15; num++) {
                Temporada temp = Temporada.builder()
                        .contenido(c)
                        .numeroTemporada(num)
                        .build();
                temps.add(temporadaRepository.save(temp));
                t++;
            }
        }
        return temps;
    }

    private void ensureEpisodios(List<Temporada> temporadas) {
        if (episodioRepository.count() >= 50) {
            return;
        }
        int ep = 0;
        for (Temporada t : temporadas) {
            for (int n = 1; n <= 4 && episodioRepository.count() < 50; n++) {
                episodioRepository.save(Episodio.builder()
                        .temporada(t)
                        .numeroEpisodio(n)
                        .tituloEpisodio("Episodio " + n)
                        .duracionMinutos(25 + n * 5)
                        .build());
                ep++;
            }
        }
    }

    private void ensureReproducciones(List<Perfil> perfiles, List<Contenido> catalogo, List<Temporada> temporadas) {
        long faltan = 200 - reproduccionRepository.count();
        if (faltan <= 0) return;
        Random rnd = new Random(7);
        List<Episodio> episodios = episodioRepository.findAll();
        for (int i = 0; i < faltan; i++) {
            Perfil p = perfiles.get(i % perfiles.size());
            Contenido c = catalogo.get(i % catalogo.size());
            Episodio ep = episodios.isEmpty() ? null : episodios.get(i % episodios.size());
            LocalDateTime inicio = LocalDateTime.of(2024, 1 + (i % 11), 1 + (i % 28), 10 + (i % 12), 0);
            reproduccionRepository.save(Reproduccion.builder()
                    .perfil(p)
                    .contenido(c)
                    .episodio(i % 3 == 0 ? ep : null)
                    .fechaHoraInicio(inicio)
                    .fechaHoraFin(inicio.plusMinutes(45 + rnd.nextInt(90)))
                    .dispositivo(DISPOSITIVOS[i % DISPOSITIVOS.length])
                    .porcentajeAvance((double) (50 + rnd.nextInt(51)))
                    .build());
        }
    }

    private void ensureCalificaciones(List<Perfil> perfiles, List<Contenido> catalogo) {
        long faltan = 60 - calificacionRepository.count();
        if (faltan <= 0) return;
        Set<String> usados = new HashSet<>();
        int creadas = 0;
        int intento = 0;
        while (creadas < faltan && intento < 500) {
            Perfil p = perfiles.get(intento % perfiles.size());
            Contenido c = catalogo.get((intento * 3) % catalogo.size());
            String key = p.getId() + "-" + c.getId();
            if (!usados.add(key)) {
                intento++;
                continue;
            }
            calificacionRepository.save(Calificacion.builder()
                    .perfil(p)
                    .contenido(c)
                    .estrellas(1 + (intento % 5))
                    .resena("Resena demo " + intento)
                    .fechaCalificacion(LocalDate.of(2024, 1, 1).plusDays(intento % 300))
                    .build());
            creadas++;
            intento++;
        }
    }

    private void ensurePagos(List<Usuario> usuarios) {
        long faltan = 80 - pagoRepository.count();
        if (faltan <= 0) return;
        double[] montos = {15900, 29900, 44900};
        for (int i = 0; i < faltan; i++) {
            Usuario u = usuarios.get(i % usuarios.size());
            long planId = u.getPlan() != null ? u.getPlan().getId() : 1L;
            boolean fallido = i % 9 == 0;
            LocalDate fecha = LocalDate.of(2024, 1, 1).plusMonths(i % 10);
            pagoRepository.save(Pago.builder()
                    .usuario(u)
                    .fechaPago(fecha)
                    .fechaVencimiento(fecha.plusMonths(1))
                    .monto(montos[(int) planId - 1])
                    .metodoPago(METODOS[i % METODOS.length])
                    .estadoPago(fallido ? "FALLIDO" : "EXITOSO")
                    .build());
        }
    }

    private void ensureFavoritos(List<Perfil> perfiles, List<Contenido> catalogo) {
        long faltan = 40 - favoritoRepository.count();
        if (faltan <= 0) return;
        Set<String> usados = new HashSet<>();
        int creados = 0;
        int i = 0;
        while (creados < faltan && i < 200) {
            Perfil p = perfiles.get(i % perfiles.size());
            Contenido c = catalogo.get((i * 2) % catalogo.size());
            String key = p.getId() + "-" + c.getId();
            if (usados.add(key)) {
                favoritoRepository.save(Favorito.builder()
                        .perfil(p)
                        .contenido(c)
                        .fechaAgregado(LocalDate.of(2024, 1, 1).plusDays(i % 200))
                        .build());
                creados++;
            }
            i++;
        }
    }

    private Plan planRef(long id) {
        return planRepository.findById(id).orElseThrow();
    }

    private Categoria categoriaRef(long id) {
        return categoriaRepository.findById(id).orElseThrow();
    }

    private void asignarGenerosSiFaltan(List<Contenido> catalogo) {
        List<Genero> todos = generoRepository.findAll();
        if (todos.isEmpty()) return;
        int idx = 0;
        for (Contenido c : catalogo) {
            if (c.getGeneros() != null && !c.getGeneros().isEmpty()) continue;
            Set<Genero> asignados = new HashSet<>();
            asignados.add(todos.get(idx % todos.size()));
            asignados.add(todos.get((idx + 1) % todos.size()));
            c.setGeneros(asignados);
            contenidoRepository.save(c);
            idx++;
        }
    }
}
