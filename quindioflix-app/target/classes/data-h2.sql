-- =====================================================
-- QUINDIOFLIX - ESTRUCTURA BASE Y DATOS DE REFERENCIA (DEMO)
-- El volumen (30 usuarios, 40 contenidos, etc.) lo genera DemoVolumeDataGenerator
-- =====================================================

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

DROP ALIAS IF EXISTS SP_CAMBIAR_PLAN;
CREATE ALIAS SP_CAMBIAR_PLAN FOR "com.quindioflix.h2.H2StoredProcedures.cambiarPlan";

-- PLANES (3)
INSERT INTO PLANES (id_plan, nombre_plan, limite_pantallas, max_perfiles, calidad, precio_mensual) VALUES (1, 'Basico', 1, 2, 'SD', 15900);
INSERT INTO PLANES (id_plan, nombre_plan, limite_pantallas, max_perfiles, calidad, precio_mensual) VALUES (2, 'Estandar', 2, 3, 'HD', 29900);
INSERT INTO PLANES (id_plan, nombre_plan, limite_pantallas, max_perfiles, calidad, precio_mensual) VALUES (3, 'Premium', 4, 5, '4K', 44900);

-- CIUDADES (3 principales + extras para asimetria en reportes)
INSERT INTO CIUDADES (id_ciudad, nombre_ciudad) VALUES (1, 'Armenia');
INSERT INTO CIUDADES (id_ciudad, nombre_ciudad) VALUES (2, 'Pereira');
INSERT INTO CIUDADES (id_ciudad, nombre_ciudad) VALUES (3, 'Manizales');
INSERT INTO CIUDADES (id_ciudad, nombre_ciudad) VALUES (4, 'Bogota');
INSERT INTO CIUDADES (id_ciudad, nombre_ciudad) VALUES (5, 'Medellin');

-- CATEGORIAS (5)
INSERT INTO CATEGORIAS (id_categoria, nombre_categoria) VALUES (1, 'Peliculas');
INSERT INTO CATEGORIAS (id_categoria, nombre_categoria) VALUES (2, 'Series');
INSERT INTO CATEGORIAS (id_categoria, nombre_categoria) VALUES (3, 'Documentales');
INSERT INTO CATEGORIAS (id_categoria, nombre_categoria) VALUES (4, 'Musica');
INSERT INTO CATEGORIAS (id_categoria, nombre_categoria) VALUES (5, 'Podcasts');

-- GENEROS (8)
INSERT INTO GENEROS (id_genero, nombre_genero) VALUES (1, 'Accion');
INSERT INTO GENEROS (id_genero, nombre_genero) VALUES (2, 'Comedia');
INSERT INTO GENEROS (id_genero, nombre_genero) VALUES (3, 'Drama');
INSERT INTO GENEROS (id_genero, nombre_genero) VALUES (4, 'Suspenso');
INSERT INTO GENEROS (id_genero, nombre_genero) VALUES (5, 'Romance');
INSERT INTO GENEROS (id_genero, nombre_genero) VALUES (6, 'Ciencia Ficcion');
INSERT INTO GENEROS (id_genero, nombre_genero) VALUES (7, 'Terror');
INSERT INTO GENEROS (id_genero, nombre_genero) VALUES (8, 'Infantil');

-- DEPARTAMENTOS Y EMPLEADOS
INSERT INTO DEPARTAMENTOS (id_departamento, nombre_departamento, id_empleado_jefe) VALUES (1, 'Tecnologia', NULL);
INSERT INTO DEPARTAMENTOS (id_departamento, nombre_departamento, id_empleado_jefe) VALUES (2, 'Contenido', NULL);
INSERT INTO EMPLEADOS (id_empleado, id_departamento, id_supervisor, nombre_empleado, email_empleado, rol_empleado, fecha_contratacion) VALUES (1, 2, NULL, 'Carlos Publicador', 'carlos@quindioflix.com', 'Editor de Contenido', DATE '2023-01-15');
