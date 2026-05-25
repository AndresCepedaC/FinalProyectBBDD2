# QuindioFlix - Plataforma de Streaming
**Proyecto Final - Bases de Datos II**

Este repositorio contiene la implementación completa de la base de datos Oracle y la API REST en Spring Boot para la plataforma de streaming QuindioFlix.

## 📂 Estructura del Proyecto

### 1. Base de Datos (`../BBDD2/sql/`)
La base de datos Oracle ha sido modelada con **20 tablas** normalizadas hasta 3FN, solucionando problemas de dependencias y agregando soporte completo para:
- Suscripciones, perfiles y límites de pantallas.
- Catálogo de contenido con temporadas y episodios.
- Tracking de reproducciones y pagos.
- Sistema de referidos e historial de planes.

Para inicializar la base de datos, ejecuta los 7 scripts `.sql` en orden en Oracle SQL Developer.

### 2. Spring Boot API (`quindioflix-app/`)
Aplicación backend construida con **Java 17** y **Spring Boot 3.2.5**.

#### Tecnologías Utilizadas
* **Spring Data JPA**: Mapeo Objeto-Relacional (ORM) usando Hibernate.
* **Spring Web**: Exposición de API RESTful.
* **Spring Security**: Configuración base y encriptación de contraseñas con BCrypt.
* **Oracle JDBC (ojdbc11)**: Conexión nativa a la base de datos Oracle.
* **Lombok**: Reducción de código repetitivo (Boilerplate).

#### Arquitectura de Software
* `model`: Entidades JPA que mapean 1 a 1 las tablas de Oracle. Incluye una `@MappedSuperclass` para campos de auditoría.
* `repository`: Interfaces de Spring Data JPA para acceso a datos.
* `service`: Lógica de negocio y transaccionalidad (`@Transactional`).
* `controller`: Endpoints de la API REST expuestos al cliente web/móvil.
* `dto`: Objetos de transferencia de datos con validaciones (`jakarta.validation`).
* `exception`: Manejo global de excepciones (`@ControllerAdvice`).
* `config`: Configuración de seguridad (CORS, CSRF, Endpoints públicos).

## 🚀 Cómo ejecutar el proyecto

1. **Base de Datos**: 
   - Abre `application.properties`.
   - Modifica `spring.datasource.url`, `username` y `password` con las credenciales de tu instancia Oracle local.
2. **Compilación**:
   - Asegúrate de tener Maven instalado.
   - Ejecuta: `mvn clean install`
3. **Ejecución**:
   - Ejecuta: `mvn spring-boot:run`
   - La API estará disponible en `http://localhost:8080/api/`

## 🔗 Endpoints Principales

- `POST /api/auth/register`: Registro de un nuevo usuario con encriptación de contraseña.
- `GET /api/contenidos`: Catálogo de películas y series paginado y ordenado por popularidad.
- `GET /api/contenidos/{id}`: Detalle de un contenido específico.
