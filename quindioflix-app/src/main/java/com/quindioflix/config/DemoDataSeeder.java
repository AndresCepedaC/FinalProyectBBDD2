package com.quindioflix.config;

import com.quindioflix.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.core.io.ClassPathResource;
import org.springframework.jdbc.datasource.init.ResourceDatabasePopulator;
import org.springframework.stereotype.Component;

import javax.sql.DataSource;

@Slf4j
@Component
@Profile("demo")
@RequiredArgsConstructor
public class DemoDataSeeder implements ApplicationRunner {

    private final UsuarioRepository usuarioRepository;
    private final ContenidoRepository contenidoRepository;
    private final PerfilRepository perfilRepository;
    private final TemporadaRepository temporadaRepository;
    private final EpisodioRepository episodioRepository;
    private final ReproduccionRepository reproduccionRepository;
    private final CalificacionRepository calificacionRepository;
    private final PagoRepository pagoRepository;
    private final FavoritoRepository favoritoRepository;
    private final DataSource dataSource;
    private final DemoVolumeDataGenerator volumeDataGenerator;

    @Override
    public void run(ApplicationArguments args) {
        if (usuarioRepository.count() == 0) {
            log.info("Cargando estructura base (data-h2.sql)...");
            var populator = new ResourceDatabasePopulator(false, false, "UTF-8",
                    new ClassPathResource("data-h2.sql"));
            populator.execute(dataSource);
        }
        if (usuarioRepository.count() < 30 || contenidoRepository.count() < 40) {
            volumeDataGenerator.generateIfNeeded();
        }
        log.info("Datos demo — usuarios:{}, perfiles:{}, contenido:{}, temporadas:{}, episodios:{}, " +
                        "reproducciones:{}, calificaciones:{}, pagos:{}, favoritos:{}",
                usuarioRepository.count(), perfilRepository.count(), contenidoRepository.count(),
                temporadaRepository.count(), episodioRepository.count(), reproduccionRepository.count(),
                calificacionRepository.count(), pagoRepository.count(), favoritoRepository.count());
    }
}
