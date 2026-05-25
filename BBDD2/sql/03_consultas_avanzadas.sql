-- =====================================================
-- QUINDIOFLIX - SCRIPT DE CONSULTAS AVANZADAS (NUCLEO 1)
-- Proyecto Final - Bases de Datos II
-- =====================================================

-- =====================================================
-- 3.1.1 Consultas parametrizadas (minimo 3)
-- =====================================================

-- a) Consulta que reciba una ciudad y muestre el top 10 de contenido mas reproducido
PROMPT 'Top 10 de contenido mas reproducido en una ciudad especifica';
UNDEFINE ciudad;
SELECT * FROM (
    SELECT c.titulo, ca.nombre_categoria, COUNT(r.id_reproduccion) as total_reproducciones
    FROM REPRODUCCIONES r
    JOIN CONTENIDO c ON r.id_contenido = c.id_contenido
    JOIN CATEGORIAS ca ON c.id_categoria = ca.id_categoria
    JOIN PERFILES p ON r.id_perfil = p.id_perfil
    JOIN USUARIOS u ON p.id_usuario = u.id_usuario
    JOIN CIUDADES ci ON u.id_ciudad = ci.id_ciudad
    WHERE ci.nombre_ciudad = '&ciudad'
    GROUP BY c.titulo, ca.nombre_categoria
    ORDER BY total_reproducciones DESC
) WHERE ROWNUM <= 10;

-- b) Consulta que reciba un mes y año y muestre los ingresos por plan
PROMPT 'Ingresos por plan de suscripcion en un periodo especifico';
UNDEFINE mes;
UNDEFINE ano;
SELECT pl.nombre_plan, SUM(pa.monto) as total_ingresos, COUNT(pa.id_pago) as cantidad_pagos
FROM PAGOS pa
JOIN USUARIOS u ON pa.id_usuario = u.id_usuario
JOIN PLANES pl ON u.id_plan = pl.id_plan
WHERE EXTRACT(MONTH FROM pa.fecha_pago) = &&mes
  AND EXTRACT(YEAR FROM pa.fecha_pago) = &&ano
  AND pa.estado_pago = 'EXITOSO'
GROUP BY pl.nombre_plan
ORDER BY total_ingresos DESC;

-- c) Consulta que reciba un genero y muestre la calificacion promedio por categoria
PROMPT 'Calificacion promedio por categoria para un genero especifico';
UNDEFINE genero;
SELECT ca.nombre_categoria, ROUND(AVG(cal.estrellas), 2) as calificacion_promedio, COUNT(cal.id_calificacion) as total_votos
FROM CALIFICACIONES cal
JOIN CONTENIDO c ON cal.id_contenido = c.id_contenido
JOIN CATEGORIAS ca ON c.id_categoria = ca.id_categoria
JOIN CONTENIDO_GENERO cg ON c.id_contenido = cg.id_contenido
JOIN GENEROS g ON cg.id_genero = g.id_genero
WHERE g.nombre_genero = '&genero'
GROUP BY ca.nombre_categoria
ORDER BY calificacion_promedio DESC;

-- =====================================================
-- 3.1.2 Tablas de referencias cruzadas (PIVOT y UNPIVOT)
-- =====================================================

-- a) PIVOT: Usuarios activos por ciudad y plan de suscripcion
PROMPT 'Reporte de usuarios activos por ciudad y plan (PIVOT)';
SELECT * FROM (
    SELECT ci.nombre_ciudad, pl.nombre_plan
    FROM USUARIOS u
    JOIN CIUDADES ci ON u.id_ciudad = ci.id_ciudad
    JOIN PLANES pl ON u.id_plan = pl.id_plan
    WHERE u.estado_cuenta = 'ACTIVO'
)
PIVOT (
    COUNT(nombre_plan)
    FOR nombre_plan IN ('Basico' AS basico, 'Estandar' AS estandar, 'Premium' AS premium)
)
ORDER BY nombre_ciudad;

-- b) PIVOT: Reproducciones por categoria y dispositivo
PROMPT 'Reporte de reproducciones por categoria y dispositivo (PIVOT)';
SELECT * FROM (
    SELECT ca.nombre_categoria, r.dispositivo
    FROM REPRODUCCIONES r
    JOIN CONTENIDO c ON r.id_contenido = c.id_contenido
    JOIN CATEGORIAS ca ON c.id_categoria = ca.id_categoria
)
PIVOT (
    COUNT(dispositivo)
    FOR dispositivo IN ('CELULAR' AS celular, 'TABLET' AS tablet, 'TV' AS tv, 'COMPUTADOR' AS pc)
)
ORDER BY nombre_categoria;

-- c) UNPIVOT: Transformar el reporte de usuarios activos
PROMPT 'Reporte transformado con UNPIVOT';
WITH usuarios_pivot AS (
    SELECT * FROM (
        SELECT ci.nombre_ciudad, pl.nombre_plan
        FROM USUARIOS u
        JOIN CIUDADES ci ON u.id_ciudad = ci.id_ciudad
        JOIN PLANES pl ON u.id_plan = pl.id_plan
    )
    PIVOT (
        COUNT(nombre_plan)
        FOR nombre_plan IN ('Basico' AS basico, 'Estandar' AS estandar, 'Premium' AS premium)
    )
)
SELECT nombre_ciudad, plan_suscripcion, cantidad_usuarios
FROM usuarios_pivot
UNPIVOT (
    cantidad_usuarios FOR plan_suscripcion IN (basico AS 'Basico', estandar AS 'Estandar', premium AS 'Premium')
);

-- =====================================================
-- 3.1.3 Funciones avanzadas del GROUP BY
-- =====================================================

-- a) ROLLUP: Ingresos por ciudad y plan con subtotales
PROMPT 'Reporte de ingresos con ROLLUP (Subtotales por ciudad y gran total)';
SELECT NVL(ci.nombre_ciudad, 'TODAS LAS CIUDADES') as ciudad, 
       NVL(pl.nombre_plan, 'TODOS LOS PLANES') as plan, 
       SUM(pa.monto) as total_ingresos
FROM PAGOS pa
JOIN USUARIOS u ON pa.id_usuario = u.id_usuario
JOIN CIUDADES ci ON u.id_ciudad = ci.id_ciudad
JOIN PLANES pl ON u.id_plan = pl.id_plan
WHERE pa.estado_pago = 'EXITOSO'
GROUP BY ROLLUP(ci.nombre_ciudad, pl.nombre_plan)
ORDER BY ci.nombre_ciudad, pl.nombre_plan;

-- b) CUBE: Reproducciones por categoria y dispositivo
PROMPT 'Reporte de reproducciones con CUBE (Todas las combinaciones)';
SELECT NVL(ca.nombre_categoria, 'TODAS LAS CATEGORIAS') as categoria, 
       NVL(r.dispositivo, 'TODOS LOS DISPOSITIVOS') as dispositivo, 
       COUNT(r.id_reproduccion) as total_reproducciones
FROM REPRODUCCIONES r
JOIN CONTENIDO c ON r.id_contenido = c.id_contenido
JOIN CATEGORIAS ca ON c.id_categoria = ca.id_categoria
GROUP BY CUBE(ca.nombre_categoria, r.dispositivo)
ORDER BY ca.nombre_categoria, r.dispositivo;

-- c) GROUPING SETS: Totales por categoria y por ciudad (sin cruzar)
PROMPT 'Reporte de totales por categoria y por ciudad (GROUPING SETS)';
SELECT NVL(ca.nombre_categoria, '---') as categoria, 
       NVL(ci.nombre_ciudad, '---') as ciudad, 
       COUNT(r.id_reproduccion) as total_reproducciones
FROM REPRODUCCIONES r
JOIN CONTENIDO c ON r.id_contenido = c.id_contenido
JOIN CATEGORIAS ca ON c.id_categoria = ca.id_categoria
JOIN PERFILES p ON r.id_perfil = p.id_perfil
JOIN USUARIOS u ON p.id_usuario = u.id_usuario
JOIN CIUDADES ci ON u.id_ciudad = ci.id_ciudad
GROUP BY GROUPING SETS (
    (ca.nombre_categoria), 
    (ci.nombre_ciudad), 
    () -- Gran total
)
ORDER BY categoria, ciudad;

-- =====================================================
-- 3.1.4 Vistas materializadas
-- =====================================================

-- a) Vista materializada: Total reproducciones y calificacion por contenido
-- Sirve como base para reportes rapidos de popularidad
CREATE MATERIALIZED VIEW MV_CONTENIDO_POPULAR
BUILD IMMEDIATE
REFRESH FORCE ON DEMAND
AS
SELECT c.id_contenido, c.titulo, ca.nombre_categoria,
       COUNT(r.id_reproduccion) as total_reproducciones,
       ROUND(AVG(cal.estrellas), 2) as calificacion_promedio
FROM CONTENIDO c
JOIN CATEGORIAS ca ON c.id_categoria = ca.id_categoria
LEFT JOIN REPRODUCCIONES r ON c.id_contenido = r.id_contenido
LEFT JOIN CALIFICACIONES cal ON c.id_contenido = cal.id_contenido
GROUP BY c.id_contenido, c.titulo, ca.nombre_categoria;

-- b) Vista materializada: Ingresos mensuales por ciudad y plan
-- Sirve como base para el reporte financiero gerencial
CREATE MATERIALIZED VIEW MV_INGRESOS_MENSUALES
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
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

-- =====================================================
-- 3.1.5 Fragmentacion de tablas (Particionamiento)
-- =====================================================

-- Nota: Esta seccion requiere permisos de creacion de tablespaces, 
-- lo cual asume un usuario con privilegios DBA. 
-- El script original creo REPRODUCCIONES sin particiones por simplicidad, 
-- pero aqui mostramos como seria el comando de creacion con fragmentacion:

/*
CREATE TABLESPACE TBS_REPROD_2024 DATAFILE 'reprod_2024.dbf' SIZE 100M AUTOEXTEND ON;
CREATE TABLESPACE TBS_REPROD_2025 DATAFILE 'reprod_2025.dbf' SIZE 100M AUTOEXTEND ON;

CREATE TABLE REPRODUCCIONES_PARTICIONADA (
    id_reproduccion     NUMBER,
    id_perfil           NUMBER,
    id_contenido        NUMBER,
    id_episodio         NUMBER,
    fecha_hora_inicio   TIMESTAMP,
    fecha_hora_fin      TIMESTAMP,
    dispositivo         VARCHAR2(20),
    porcentaje_avance   NUMBER(5,2)
)
PARTITION BY RANGE (fecha_hora_inicio) (
    PARTITION p_2024 VALUES LESS THAN (TO_DATE('2025-01-01', 'YYYY-MM-DD')) TABLESPACE TBS_REPROD_2024,
    PARTITION p_2025 VALUES LESS THAN (TO_DATE('2026-01-01', 'YYYY-MM-DD')) TABLESPACE TBS_REPROD_2025,
    PARTITION p_max VALUES LESS THAN (MAXVALUE)
);

Justificacion:
La tabla REPRODUCCIONES es la mas transaccional y grande del sistema.
Fragmentarla por rango de fechas (fecha_hora_inicio) permite:
1. Mejorar el rendimiento de consultas que filtran por un periodo especifico (Partition Pruning).
2. Facilitar el mantenimiento y el archivado (data archiving) de datos antiguos.
3. Distribuir el I/O en multiples datafiles.
*/
