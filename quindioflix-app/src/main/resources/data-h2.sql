-- =====================================================
-- QUINDIOFLIX - DATOS SEMILLA PARA H2 (DEMO)
-- =====================================================

-- VISTAS SIMULADAS EN H2 (Materialized Views de Oracle)
DROP VIEW IF EXISTS MV_CONTENIDO_POPULAR;
CREATE VIEW MV_CONTENIDO_POPULAR AS
SELECT c.id_contenido, c.titulo, ca.nombre_categoria,
       COUNT(r.id_reproduccion) as total_reproducciones,
       ROUND(AVG(cal.estrellas), 2) as calificacion_promedio
FROM CONTENIDO c
JOIN CATEGORIAS ca ON c.id_categoria = ca.id_categoria
LEFT JOIN REPRODUCCIONES r ON c.id_contenido = r.id_contenido
LEFT JOIN CALIFICACIONES cal ON c.id_contenido = cal.id_contenido
GROUP BY c.id_contenido, c.titulo, ca.nombre_categoria;

DROP VIEW IF EXISTS MV_INGRESOS_MENSUALES;
CREATE VIEW MV_INGRESOS_MENSUALES AS
SELECT ci.nombre_ciudad, pl.nombre_plan, 
       EXTRACT(YEAR FROM pa.fecha_pago) as anio,
       EXTRACT(MONTH FROM pa.fecha_pago) as mes,
       SUM(pa.monto) as total_ingresos,
       COUNT(pa.id_pago) as cantidad_pagos
FROM PAGOS pa
JOIN USUARIOS u ON pa.id_usuario = u.id_usuario
JOIN CIUDADES ci ON u.id_ciudad = ci.id_ciudad
JOIN PLANES pl ON u.id_plan = pl.id_plan
WHERE pa.estado_pago = 'EXITOSO'
GROUP BY ci.nombre_ciudad, pl.nombre_plan, EXTRACT(YEAR FROM pa.fecha_pago), EXTRACT(MONTH FROM pa.fecha_pago);

-- SIMULACION DE PROCEDIMIENTO ALMACENADO SP_CAMBIAR_PLAN EN H2
DROP ALIAS IF EXISTS SP_CAMBIAR_PLAN;
CREATE ALIAS SP_CAMBIAR_PLAN FOR "com.quindioflix.h2.H2StoredProcedures.cambiarPlan";


-- PLANES
INSERT INTO PLANES (id_plan, nombre_plan, limite_pantallas, max_perfiles, calidad, precio_mensual) VALUES (1, 'Basico', 1, 2, 'SD', 15900);
INSERT INTO PLANES (id_plan, nombre_plan, limite_pantallas, max_perfiles, calidad, precio_mensual) VALUES (2, 'Estandar', 2, 3, 'HD', 29900);
INSERT INTO PLANES (id_plan, nombre_plan, limite_pantallas, max_perfiles, calidad, precio_mensual) VALUES (3, 'Premium', 4, 5, '4K', 44900);

-- CIUDADES
INSERT INTO CIUDADES (id_ciudad, nombre_ciudad) VALUES (1, 'Armenia');
INSERT INTO CIUDADES (id_ciudad, nombre_ciudad) VALUES (2, 'Pereira');
INSERT INTO CIUDADES (id_ciudad, nombre_ciudad) VALUES (3, 'Manizales');
INSERT INTO CIUDADES (id_ciudad, nombre_ciudad) VALUES (4, 'Bogota');
INSERT INTO CIUDADES (id_ciudad, nombre_ciudad) VALUES (5, 'Medellin');
INSERT INTO CIUDADES (id_ciudad, nombre_ciudad) VALUES (6, 'Cali');
INSERT INTO CIUDADES (id_ciudad, nombre_ciudad) VALUES (7, 'Barranquilla');
INSERT INTO CIUDADES (id_ciudad, nombre_ciudad) VALUES (8, 'Cartagena');

-- CATEGORIAS
INSERT INTO CATEGORIAS (id_categoria, nombre_categoria) VALUES (1, 'Peliculas');
INSERT INTO CATEGORIAS (id_categoria, nombre_categoria) VALUES (2, 'Series');
INSERT INTO CATEGORIAS (id_categoria, nombre_categoria) VALUES (3, 'Documentales');
INSERT INTO CATEGORIAS (id_categoria, nombre_categoria) VALUES (4, 'Musica');
INSERT INTO CATEGORIAS (id_categoria, nombre_categoria) VALUES (5, 'Podcasts');

-- GENEROS
INSERT INTO GENEROS (id_genero, nombre_genero) VALUES (1, 'Accion');
INSERT INTO GENEROS (id_genero, nombre_genero) VALUES (2, 'Comedia');
INSERT INTO GENEROS (id_genero, nombre_genero) VALUES (3, 'Drama');
INSERT INTO GENEROS (id_genero, nombre_genero) VALUES (4, 'Terror');
INSERT INTO GENEROS (id_genero, nombre_genero) VALUES (5, 'Romance');
INSERT INTO GENEROS (id_genero, nombre_genero) VALUES (6, 'Ciencia Ficcion');
INSERT INTO GENEROS (id_genero, nombre_genero) VALUES (7, 'Animacion');
INSERT INTO GENEROS (id_genero, nombre_genero) VALUES (8, 'Suspenso');

-- DEPARTAMENTOS
INSERT INTO DEPARTAMENTOS (id_departamento, nombre_departamento, id_empleado_jefe) VALUES (1, 'Tecnologia', NULL);
INSERT INTO DEPARTAMENTOS (id_departamento, nombre_departamento, id_empleado_jefe) VALUES (2, 'Contenido', NULL);
INSERT INTO DEPARTAMENTOS (id_departamento, nombre_departamento, id_empleado_jefe) VALUES (3, 'Marketing', NULL);

-- EMPLEADOS
INSERT INTO EMPLEADOS (id_empleado, id_departamento, id_supervisor, nombre_empleado, email_empleado, rol_empleado, fecha_contratacion) VALUES (1, 2, NULL, 'Carlos Publicador', 'carlos@quindioflix.com', 'Editor de Contenido', DATE '2023-01-15');
INSERT INTO EMPLEADOS (id_empleado, id_departamento, id_supervisor, nombre_empleado, email_empleado, rol_empleado, fecha_contratacion) VALUES (2, 1, NULL, 'Ana Devops', 'ana@quindioflix.com', 'Ingeniera de Software', DATE '2023-03-01');

-- CONTENIDO (20 titulos variados)
INSERT INTO CONTENIDO (id_contenido, id_categoria, id_empleado_publicador, titulo, ano_lanzamiento, duracion_minutos, sinopsis, clasificacion_edad, fecha_creacion, es_original, popularidad, estado) VALUES (1, 1, 1, 'El Ultimo Guardian', 2024, 142, 'Un guerrero solitario protege una aldea de invasores en los Andes colombianos.', '+13', CURRENT_TIMESTAMP, 1, 95, 'ACTIVO');
INSERT INTO CONTENIDO (id_contenido, id_categoria, id_empleado_publicador, titulo, ano_lanzamiento, duracion_minutos, sinopsis, clasificacion_edad, fecha_creacion, es_original, popularidad, estado) VALUES (2, 1, 1, 'Conexion Digital', 2023, 118, 'Un hacker descubre una conspiracion gubernamental a traves de la dark web.', '+16', CURRENT_TIMESTAMP, 0, 88, 'ACTIVO');
INSERT INTO CONTENIDO (id_contenido, id_categoria, id_empleado_publicador, titulo, ano_lanzamiento, duracion_minutos, sinopsis, clasificacion_edad, fecha_creacion, es_original, popularidad, estado) VALUES (3, 2, 1, 'Cafe y Secretos', 2024, NULL, 'Drama familiar ambientado en las fincas cafeteras del Quindio.', '+13', CURRENT_TIMESTAMP, 1, 92, 'ACTIVO');
INSERT INTO CONTENIDO (id_contenido, id_categoria, id_empleado_publicador, titulo, ano_lanzamiento, duracion_minutos, sinopsis, clasificacion_edad, fecha_creacion, es_original, popularidad, estado) VALUES (4, 1, 1, 'Noches de Tango', 2022, 130, 'Una historia de amor prohibido en el Buenos Aires de los anos 40.', '+16', CURRENT_TIMESTAMP, 0, 76, 'ACTIVO');
INSERT INTO CONTENIDO (id_contenido, id_categoria, id_empleado_publicador, titulo, ano_lanzamiento, duracion_minutos, sinopsis, clasificacion_edad, fecha_creacion, es_original, popularidad, estado) VALUES (5, 3, 1, 'Biodiversidad Oculta', 2024, 95, 'Documental sobre especies endemicas del Eje Cafetero colombiano.', 'TP', CURRENT_TIMESTAMP, 1, 84, 'ACTIVO');
INSERT INTO CONTENIDO (id_contenido, id_categoria, id_empleado_publicador, titulo, ano_lanzamiento, duracion_minutos, sinopsis, clasificacion_edad, fecha_creacion, es_original, popularidad, estado) VALUES (6, 1, 1, 'Codigo Rojo', 2023, 110, 'Un equipo de elite enfrenta una amenaza biologica en Latinoamerica.', '+18', CURRENT_TIMESTAMP, 0, 91, 'ACTIVO');
INSERT INTO CONTENIDO (id_contenido, id_categoria, id_empleado_publicador, titulo, ano_lanzamiento, duracion_minutos, sinopsis, clasificacion_edad, fecha_creacion, es_original, popularidad, estado) VALUES (7, 2, 1, 'La Herencia', 2023, NULL, 'Tres hermanos descubren que su padre les dejo mas que dinero.', '+13', CURRENT_TIMESTAMP, 1, 87, 'ACTIVO');
INSERT INTO CONTENIDO (id_contenido, id_categoria, id_empleado_publicador, titulo, ano_lanzamiento, duracion_minutos, sinopsis, clasificacion_edad, fecha_creacion, es_original, popularidad, estado) VALUES (8, 1, 1, 'Vuelo 404', 2024, 98, 'Los pasajeros de un vuelo comercial despiertan en una realidad alterna.', '+13', CURRENT_TIMESTAMP, 0, 79, 'ACTIVO');
INSERT INTO CONTENIDO (id_contenido, id_categoria, id_empleado_publicador, titulo, ano_lanzamiento, duracion_minutos, sinopsis, clasificacion_edad, fecha_creacion, es_original, popularidad, estado) VALUES (9, 1, 1, 'Aventuras en el Cocora', 2024, 85, 'Animacion sobre un grupo de animales que protegen el Valle del Cocora.', 'TP', CURRENT_TIMESTAMP, 1, 93, 'ACTIVO');
INSERT INTO CONTENIDO (id_contenido, id_categoria, id_empleado_publicador, titulo, ano_lanzamiento, duracion_minutos, sinopsis, clasificacion_edad, fecha_creacion, es_original, popularidad, estado) VALUES (10, 3, 1, 'Voces del Conflicto', 2022, 120, 'Testimonios reales de sobrevivientes del conflicto armado colombiano.', '+16', CURRENT_TIMESTAMP, 1, 81, 'ACTIVO');
INSERT INTO CONTENIDO (id_contenido, id_categoria, id_empleado_publicador, titulo, ano_lanzamiento, duracion_minutos, sinopsis, clasificacion_edad, fecha_creacion, es_original, popularidad, estado) VALUES (11, 1, 1, 'Sombras del Pasado', 2023, 135, 'Un detective retirado vuelve a investigar el caso que arruino su carrera.', '+16', CURRENT_TIMESTAMP, 0, 73, 'ACTIVO');
INSERT INTO CONTENIDO (id_contenido, id_categoria, id_empleado_publicador, titulo, ano_lanzamiento, duracion_minutos, sinopsis, clasificacion_edad, fecha_creacion, es_original, popularidad, estado) VALUES (12, 2, 1, 'Startup Valley', 2024, NULL, 'La vida caotica de emprendedores tech en Silicon Valley latinoamericano.', '+13', CURRENT_TIMESTAMP, 1, 86, 'ACTIVO');

-- CONTENIDO_GENERO
INSERT INTO CONTENIDO_GENERO (id_contenido, id_genero) VALUES (1, 1);
INSERT INTO CONTENIDO_GENERO (id_contenido, id_genero) VALUES (1, 3);
INSERT INTO CONTENIDO_GENERO (id_contenido, id_genero) VALUES (2, 1);
INSERT INTO CONTENIDO_GENERO (id_contenido, id_genero) VALUES (2, 8);
INSERT INTO CONTENIDO_GENERO (id_contenido, id_genero) VALUES (3, 3);
INSERT INTO CONTENIDO_GENERO (id_contenido, id_genero) VALUES (3, 5);
INSERT INTO CONTENIDO_GENERO (id_contenido, id_genero) VALUES (4, 3);
INSERT INTO CONTENIDO_GENERO (id_contenido, id_genero) VALUES (4, 5);
INSERT INTO CONTENIDO_GENERO (id_contenido, id_genero) VALUES (5, 3);
INSERT INTO CONTENIDO_GENERO (id_contenido, id_genero) VALUES (6, 1);
INSERT INTO CONTENIDO_GENERO (id_contenido, id_genero) VALUES (6, 8);
INSERT INTO CONTENIDO_GENERO (id_contenido, id_genero) VALUES (7, 3);
INSERT INTO CONTENIDO_GENERO (id_contenido, id_genero) VALUES (8, 6);
INSERT INTO CONTENIDO_GENERO (id_contenido, id_genero) VALUES (8, 8);
INSERT INTO CONTENIDO_GENERO (id_contenido, id_genero) VALUES (9, 7);
INSERT INTO CONTENIDO_GENERO (id_contenido, id_genero) VALUES (10, 3);
INSERT INTO CONTENIDO_GENERO (id_contenido, id_genero) VALUES (11, 8);
INSERT INTO CONTENIDO_GENERO (id_contenido, id_genero) VALUES (12, 2);

-- USUARIOS DE PRUEBA (contrasena: 123456 hasheada con BCrypt)
INSERT INTO USUARIOS (id_usuario, id_plan, id_ciudad, id_referidor, nombre_completo, email, contrasena_hash, telefono, fecha_nacimiento, fecha_registro, estado_cuenta, fecha_ultimo_pago) VALUES (1, 3, 1, NULL, 'Andres Cepeda Demo', 'andres@demo.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', '3001234567', DATE '1995-06-15', DATE '2024-01-10', 'ACTIVO', DATE '2024-12-01');
INSERT INTO USUARIOS (id_usuario, id_plan, id_ciudad, id_referidor, nombre_completo, email, contrasena_hash, telefono, fecha_nacimiento, fecha_registro, estado_cuenta, fecha_ultimo_pago) VALUES (2, 2, 4, 1, 'Maria Garcia', 'maria@demo.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', '3109876543', DATE '1990-03-22', DATE '2024-02-15', 'ACTIVO', DATE '2024-11-15');
INSERT INTO USUARIOS (id_usuario, id_plan, id_ciudad, id_referidor, nombre_completo, email, contrasena_hash, telefono, fecha_nacimiento, fecha_registro, estado_cuenta, fecha_ultimo_pago) VALUES (3, 1, 5, NULL, 'Juan Lopez', 'juan@demo.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', NULL, DATE '1988-11-05', DATE '2024-05-01', 'SUSPENDIDO', DATE '2024-08-01');
INSERT INTO USUARIOS (id_usuario, id_plan, id_ciudad, id_referidor, nombre_completo, email, contrasena_hash, telefono, fecha_nacimiento, fecha_registro, estado_cuenta, fecha_ultimo_pago) VALUES (4, 3, 1, NULL, 'Administrador QFlix', 'admin@demo.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', '3009999999', DATE '1985-01-01', DATE '2024-01-01', 'ACTIVO', DATE '2024-12-01');

-- PERFILES
INSERT INTO PERFILES (id_perfil, id_usuario, nombre_perfil, avatar, tipo_perfil, fecha_creacion) VALUES (1, 1, 'Andres', 'avatar1.png', 'ADULTO', CURRENT_TIMESTAMP);
INSERT INTO PERFILES (id_perfil, id_usuario, nombre_perfil, avatar, tipo_perfil, fecha_creacion) VALUES (2, 1, 'Hijo de Andres', 'avatar_kid.png', 'INFANTIL', CURRENT_TIMESTAMP);
INSERT INTO PERFILES (id_perfil, id_usuario, nombre_perfil, avatar, tipo_perfil, fecha_creacion) VALUES (3, 2, 'Maria', 'avatar2.png', 'ADULTO', CURRENT_TIMESTAMP);
INSERT INTO PERFILES (id_perfil, id_usuario, nombre_perfil, avatar, tipo_perfil, fecha_creacion) VALUES (4, 3, 'Juan', 'avatar3.png', 'ADULTO', CURRENT_TIMESTAMP);
INSERT INTO PERFILES (id_perfil, id_usuario, nombre_perfil, avatar, tipo_perfil, fecha_creacion) VALUES (5, 4, 'AdminPer', 'avatar_admin.png', 'ADULTO', CURRENT_TIMESTAMP);

-- REPRODUCCIONES
INSERT INTO REPRODUCCIONES (id_reproduccion, id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (1, 1, 1, NULL, TIMESTAMP '2024-11-15 20:00:00', TIMESTAMP '2024-11-15 22:22:00', 'TV', 100);
INSERT INTO REPRODUCCIONES (id_reproduccion, id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (2, 1, 2, NULL, TIMESTAMP '2024-11-16 19:30:00', TIMESTAMP '2024-11-16 21:28:00', 'COMPUTADOR', 100);
INSERT INTO REPRODUCCIONES (id_reproduccion, id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (3, 3, 1, NULL, TIMESTAMP '2024-11-17 21:00:00', TIMESTAMP '2024-11-17 23:22:00', 'CELULAR', 100);
INSERT INTO REPRODUCCIONES (id_reproduccion, id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (4, 2, 9, NULL, TIMESTAMP '2024-11-18 15:00:00', TIMESTAMP '2024-11-18 16:25:00', 'TABLET', 100);
INSERT INTO REPRODUCCIONES (id_reproduccion, id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (5, 1, 5, NULL, TIMESTAMP '2024-11-19 20:00:00', NULL, 'TV', 45);

-- PAGOS
INSERT INTO PAGOS (id_pago, id_usuario, fecha_pago, fecha_vencimiento, monto, metodo_pago, estado_pago) VALUES (1, 1, DATE '2024-12-01', DATE '2025-01-01', 44900, 'TARJETA_CREDITO', 'EXITOSO');
INSERT INTO PAGOS (id_pago, id_usuario, fecha_pago, fecha_vencimiento, monto, metodo_pago, estado_pago) VALUES (2, 1, DATE '2024-11-01', DATE '2024-12-01', 44900, 'TARJETA_CREDITO', 'EXITOSO');
INSERT INTO PAGOS (id_pago, id_usuario, fecha_pago, fecha_vencimiento, monto, metodo_pago, estado_pago) VALUES (3, 2, DATE '2024-11-15', DATE '2024-12-15', 29900, 'NEQUI', 'EXITOSO');
INSERT INTO PAGOS (id_pago, id_usuario, fecha_pago, fecha_vencimiento, monto, metodo_pago, estado_pago) VALUES (4, 3, DATE '2024-08-01', DATE '2024-09-01', 15900, 'PSE', 'EXITOSO');

-- HISTORIAL_PLANES
INSERT INTO HISTORIAL_PLANES (id_historial, id_usuario, id_plan_anterior, id_plan_nuevo, fecha_cambio, motivo) VALUES (1, 1, 2, 3, DATE '2024-06-01', 'Upgrade a Premium por mas pantallas');

-- REINICIAR SECUENCIAS PARA EVITAR CONFLICTOS DE LLAVE PRIMARIA
ALTER SEQUENCE SEQ_USUARIOS RESTART WITH 100;
ALTER SEQUENCE SEQ_PLANES RESTART WITH 100;
ALTER SEQUENCE SEQ_REPRODUCCIONES RESTART WITH 100;
ALTER SEQUENCE SEQ_CALIFICACIONES RESTART WITH 100;
ALTER SEQUENCE SEQ_EMPLEADOS RESTART WITH 100;
ALTER SEQUENCE SEQ_CATEGORIAS RESTART WITH 100;
ALTER SEQUENCE SEQ_PERFILES RESTART WITH 100;
ALTER SEQUENCE SEQ_HISTORIAL_PLANES RESTART WITH 100;
ALTER SEQUENCE SEQ_DESCUENTOS_REFERIDOS RESTART WITH 100;
ALTER SEQUENCE SEQ_FAVORITOS RESTART WITH 100;
ALTER SEQUENCE SEQ_DEPARTAMENTOS RESTART WITH 100;
ALTER SEQUENCE SEQ_CIUDADES RESTART WITH 100;
ALTER SEQUENCE SEQ_TEMPORADAS RESTART WITH 100;
ALTER SEQUENCE SEQ_PAGOS RESTART WITH 100;
ALTER SEQUENCE SEQ_CONTENIDO RESTART WITH 100;
ALTER SEQUENCE SEQ_GENEROS RESTART WITH 100;
ALTER SEQUENCE SEQ_EPISODIOS RESTART WITH 100;

