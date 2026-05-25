-- =====================================================
-- QUINDIOFLIX - SCRIPT DE INDICES (NUCLEO 4)
-- Proyecto Final - Bases de Datos II
-- =====================================================

-- =====================================================
-- 3.4.1 Creacion y administracion de indices (minimo 4)
-- =====================================================

-- a) Indice compuesto en REPRODUCCIONES
-- Justificacion: Esta combinacion es la mas consultada para mostrar el 
-- historial de visualizacion ("Continuar viendo") de un perfil especifico 
-- ordenado por fecha descendente.
CREATE INDEX IDX_REPR_PERFIL_FECHA ON REPRODUCCIONES (id_perfil, fecha_hora_inicio DESC);

-- b) Indice en USUARIOS(email)
-- NOTA: El constraint UNIQUE de la tabla ya crea un indice unico implicito,
-- pero para documentar, aqui esta como seria (no se ejecuta por que fallaria por duplicado)
-- Justificacion: Esencial para el proceso de autenticacion (Login) donde se busca
-- rapidamente al usuario por su correo, que ademas debe ser unico.
-- CREATE UNIQUE INDEX IDX_USUARIOS_EMAIL ON USUARIOS (email);

-- c) Indice compuesto en CONTENIDO
-- Justificacion: Optimiza las busquedas del catalogo cuando los usuarios 
-- filtran por una categoria especifica y ordenan o filtran por ano de lanzamiento.
CREATE INDEX IDX_CONT_CAT_ANO ON CONTENIDO (id_categoria, ano_lanzamiento DESC);

-- d) Indice adicional: Pagos por Usuario y Fecha
-- Justificacion: Optimiza la generacion de reportes de facturacion (historial de pagos) 
-- para un usuario, los cuales se ordenan por la fecha de pago mas reciente.
CREATE INDEX IDX_PAGOS_USU_FECHA ON PAGOS (id_usuario, fecha_pago DESC);

-- e) Indice adicional: Popularidad del contenido
-- Justificacion: Soporta la consulta frecuente de "Top Contenido" o
-- la seccion "Tendencias" de la pagina principal.
CREATE INDEX IDX_CONTENIDO_POPULARIDAD ON CONTENIDO (popularidad DESC);


-- =====================================================
-- 3.4.2 Analisis de rendimiento (EXPLAIN PLAN)
-- =====================================================

/*
-- INSTRUCCIONES PARA LA SUSTENTACION:
-- Ejecutar estos comandos en SQL Developer o SQL*Plus.

-- 1. Asegurarse que el indice NO existe
DROP INDEX IDX_REPR_PERFIL_FECHA;

-- 2. Limpiar cache para tener resultados reales
ALTER SYSTEM FLUSH BUFFER_CACHE;

-- 3. Generar Plan ANTES del indice
EXPLAIN PLAN FOR
SELECT c.titulo, r.porcentaje_avance, r.fecha_hora_inicio
FROM REPRODUCCIONES r
JOIN CONTENIDO c ON r.id_contenido = c.id_contenido
WHERE r.id_perfil = 10
ORDER BY r.fecha_hora_inicio DESC;

-- 4. Ver el plan (Tomar captura de FULL TABLE SCAN)
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- 5. Crear el indice
CREATE INDEX IDX_REPR_PERFIL_FECHA ON REPRODUCCIONES (id_perfil, fecha_hora_inicio DESC);

-- 6. Recolectar estadisticas de la tabla para que el optimizador vea el indice
EXEC DBMS_STATS.GATHER_TABLE_STATS(USER, 'REPRODUCCIONES');

-- 7. Generar Plan DESPUES del indice
EXPLAIN PLAN FOR
SELECT c.titulo, r.porcentaje_avance, r.fecha_hora_inicio
FROM REPRODUCCIONES r
JOIN CONTENIDO c ON r.id_contenido = c.id_contenido
WHERE r.id_perfil = 10
ORDER BY r.fecha_hora_inicio DESC;

-- 8. Ver el plan (Tomar captura de INDEX RANGE SCAN y menor Costo/CPU)
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

*/
