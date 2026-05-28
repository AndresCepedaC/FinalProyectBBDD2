package com.quindioflix.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;
import java.util.List;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .csrf(AbstractHttpConfigurer::disable) // Deshabilitado para simplificar la API REST
            .authorizeHttpRequests(auth -> auth
                // Recursos estaticos del frontend
                .requestMatchers("/", "/*.html", "/*.css", "/*.js", "/favicon.ico").permitAll()
                // Endpoints publicos de registro/login
                .requestMatchers("/api/auth/**").permitAll()
                // Catalogo publico
                .requestMatchers("/api/public/**").permitAll()
                // Catalogo de contenidos (GET)
                .requestMatchers("/api/contenidos/**").permitAll()
                .requestMatchers("/api/contenidos").permitAll()
                // Usuarios y reportes abiertos para modo demo (sin JWT implementado)
                .requestMatchers("/api/usuarios/**").permitAll()
                .requestMatchers("/api/reportes/**").permitAll()
                // Health check
                .requestMatchers("/actuator/health").permitAll()
                .anyRequest().permitAll() // Demo mode: todo abierto
            )
            .httpBasic(AbstractHttpConfigurer::disable);
            
        return http.build();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOrigins(List.of("*"));
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"));
        configuration.setAllowedHeaders(List.of("*"));
        configuration.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
