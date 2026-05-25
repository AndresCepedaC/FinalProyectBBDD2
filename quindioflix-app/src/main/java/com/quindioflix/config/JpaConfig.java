package com.quindioflix.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

@Configuration
@EnableJpaAuditing
public class JpaConfig {
    // Esta configuracion habilita la auditoria de JPA.
    // Combinado con @EntityListeners(AuditingEntityListener.class) y @CreatedDate
    // permite el llenado automatico de campos de auditoria de forma profesional.
}
