-- =====================================================
-- QUINDIOFLIX - SCRIPT DE INSERCION DE DATOS
-- Proyecto Final - Bases de Datos II
-- =====================================================

-- 1. PLANES (3 registros)
INSERT INTO PLANES (id_plan, nombre_plan, limite_pantallas, max_perfiles, calidad, precio_mensual) VALUES (SEQ_PLANES.NEXTVAL, 'Basico', 1, 2, 'SD', 14900);
INSERT INTO PLANES (id_plan, nombre_plan, limite_pantallas, max_perfiles, calidad, precio_mensual) VALUES (SEQ_PLANES.NEXTVAL, 'Estandar', 2, 3, 'HD', 24900);
INSERT INTO PLANES (id_plan, nombre_plan, limite_pantallas, max_perfiles, calidad, precio_mensual) VALUES (SEQ_PLANES.NEXTVAL, 'Premium', 4, 5, '4K', 34900);

-- 2. CIUDADES (5 registros)
INSERT INTO CIUDADES (id_ciudad, nombre_ciudad) VALUES (SEQ_CIUDADES.NEXTVAL, 'Bogota');
INSERT INTO CIUDADES (id_ciudad, nombre_ciudad) VALUES (SEQ_CIUDADES.NEXTVAL, 'Medellin');
INSERT INTO CIUDADES (id_ciudad, nombre_ciudad) VALUES (SEQ_CIUDADES.NEXTVAL, 'Armenia');
INSERT INTO CIUDADES (id_ciudad, nombre_ciudad) VALUES (SEQ_CIUDADES.NEXTVAL, 'Cali');
INSERT INTO CIUDADES (id_ciudad, nombre_ciudad) VALUES (SEQ_CIUDADES.NEXTVAL, 'Barranquilla');

-- 3. USUARIOS (35 registros asimetricos)
-- Distribuimos con mas peso en Bogota (1) y Medellin (2), y en planes Basico (1)
BEGIN
    FOR i IN 1..15 LOOP
        INSERT INTO USUARIOS (id_usuario, id_plan, id_ciudad, id_referidor, nombre_completo, email, contrasena_hash, telefono, fecha_nacimiento, fecha_registro, estado_cuenta)
        VALUES (SEQ_USUARIOS.NEXTVAL, 1, 1, NULL, 'Usuario Bogota Basico '||i, 'usr.bog.bas'||i||'@email.com', 'hash123', '30012345'||i, TO_DATE('1990-01-01', 'YYYY-MM-DD'), SYSDATE - (100+i), 'ACTIVO');
    END LOOP;
    
    FOR i IN 1..10 LOOP
        INSERT INTO USUARIOS (id_usuario, id_plan, id_ciudad, id_referidor, nombre_completo, email, contrasena_hash, telefono, fecha_nacimiento, fecha_registro, estado_cuenta)
        VALUES (SEQ_USUARIOS.NEXTVAL, 2, 2, 1, 'Usuario Medellin Estandar '||i, 'usr.med.est'||i||'@email.com', 'hash123', '31012345'||i, TO_DATE('1985-05-15', 'YYYY-MM-DD'), SYSDATE - (50+i), 'ACTIVO');
    END LOOP;

    FOR i IN 1..5 LOOP
        INSERT INTO USUARIOS (id_usuario, id_plan, id_ciudad, id_referidor, nombre_completo, email, contrasena_hash, telefono, fecha_nacimiento, fecha_registro, estado_cuenta)
        VALUES (SEQ_USUARIOS.NEXTVAL, 3, 3, 2, 'Usuario Armenia Premium '||i, 'usr.arm.pre'||i||'@email.com', 'hash123', '32012345'||i, TO_DATE('2000-10-20', 'YYYY-MM-DD'), SYSDATE - (20+i), 'ACTIVO');
    END LOOP;

    FOR i IN 1..5 LOOP
        INSERT INTO USUARIOS (id_usuario, id_plan, id_ciudad, id_referidor, nombre_completo, email, contrasena_hash, telefono, fecha_nacimiento, fecha_registro, estado_cuenta)
        VALUES (SEQ_USUARIOS.NEXTVAL, 1, 4, NULL, 'Usuario Cali Basico '||i, 'usr.cal.bas'||i||'@email.com', 'hash123', '31512345'||i, TO_DATE('1995-12-05', 'YYYY-MM-DD'), SYSDATE - (10+i), 'ACTIVO');
    END LOOP;
END;
/

-- 4. PERFILES (55 registros)
BEGIN
    FOR i IN 1..35 LOOP
        -- Perfil adulto para todos
        INSERT INTO PERFILES (id_perfil, id_usuario, nombre_perfil, avatar, tipo_perfil)
        VALUES (SEQ_PERFILES.NEXTVAL, i, 'Principal '||i, 'avatar1.png', 'ADULTO');
    END LOOP;
    
    FOR i IN 1..20 LOOP
        -- Perfil infantil para algunos
        INSERT INTO PERFILES (id_perfil, id_usuario, nombre_perfil, avatar, tipo_perfil)
        VALUES (SEQ_PERFILES.NEXTVAL, i, 'Kids '||i, 'avatar_kid.png', 'INFANTIL');
    END LOOP;
END;
/

-- 5. CATEGORIAS (5 registros)
INSERT INTO CATEGORIAS (id_categoria, nombre_categoria) VALUES (SEQ_CATEGORIAS.NEXTVAL, 'Peliculas');
INSERT INTO CATEGORIAS (id_categoria, nombre_categoria) VALUES (SEQ_CATEGORIAS.NEXTVAL, 'Series');
INSERT INTO CATEGORIAS (id_categoria, nombre_categoria) VALUES (SEQ_CATEGORIAS.NEXTVAL, 'Documentales');
INSERT INTO CATEGORIAS (id_categoria, nombre_categoria) VALUES (SEQ_CATEGORIAS.NEXTVAL, 'Musica');
INSERT INTO CATEGORIAS (id_categoria, nombre_categoria) VALUES (SEQ_CATEGORIAS.NEXTVAL, 'Podcasts');

-- 6. GENEROS (10 registros)
INSERT INTO GENEROS (id_genero, nombre_genero) VALUES (SEQ_GENEROS.NEXTVAL, 'Accion');
INSERT INTO GENEROS (id_genero, nombre_genero) VALUES (SEQ_GENEROS.NEXTVAL, 'Comedia');
INSERT INTO GENEROS (id_genero, nombre_genero) VALUES (SEQ_GENEROS.NEXTVAL, 'Drama');
INSERT INTO GENEROS (id_genero, nombre_genero) VALUES (SEQ_GENEROS.NEXTVAL, 'Suspenso');
INSERT INTO GENEROS (id_genero, nombre_genero) VALUES (SEQ_GENEROS.NEXTVAL, 'Romance');
INSERT INTO GENEROS (id_genero, nombre_genero) VALUES (SEQ_GENEROS.NEXTVAL, 'Ciencia Ficcion');
INSERT INTO GENEROS (id_genero, nombre_genero) VALUES (SEQ_GENEROS.NEXTVAL, 'Terror');
INSERT INTO GENEROS (id_genero, nombre_genero) VALUES (SEQ_GENEROS.NEXTVAL, 'Infantil');
INSERT INTO GENEROS (id_genero, nombre_genero) VALUES (SEQ_GENEROS.NEXTVAL, 'Documental');
INSERT INTO GENEROS (id_genero, nombre_genero) VALUES (SEQ_GENEROS.NEXTVAL, 'Musical');

-- 7. DEPARTAMENTOS Y 8. EMPLEADOS
INSERT INTO DEPARTAMENTOS (id_departamento, nombre_departamento, id_empleado_jefe) VALUES (SEQ_DEPARTAMENTOS.NEXTVAL, 'Tecnologia', NULL);
INSERT INTO DEPARTAMENTOS (id_departamento, nombre_departamento, id_empleado_jefe) VALUES (SEQ_DEPARTAMENTOS.NEXTVAL, 'Contenido', NULL);
INSERT INTO DEPARTAMENTOS (id_departamento, nombre_departamento, id_empleado_jefe) VALUES (SEQ_DEPARTAMENTOS.NEXTVAL, 'Marketing', NULL);
INSERT INTO DEPARTAMENTOS (id_departamento, nombre_departamento, id_empleado_jefe) VALUES (SEQ_DEPARTAMENTOS.NEXTVAL, 'Soporte', NULL);

INSERT INTO EMPLEADOS (id_empleado, id_departamento, id_supervisor, nombre_empleado, email_empleado, rol_empleado) VALUES (SEQ_EMPLEADOS.NEXTVAL, 1, NULL, 'Jefe Tech', 'tech@qflix.com', 'Director IT');
INSERT INTO EMPLEADOS (id_empleado, id_departamento, id_supervisor, nombre_empleado, email_empleado, rol_empleado) VALUES (SEQ_EMPLEADOS.NEXTVAL, 2, NULL, 'Jefe Contenido', 'cont@qflix.com', 'Director Contenido');
INSERT INTO EMPLEADOS (id_empleado, id_departamento, id_supervisor, nombre_empleado, email_empleado, rol_empleado) VALUES (SEQ_EMPLEADOS.NEXTVAL, 3, NULL, 'Jefe Marketing', 'mkt@qflix.com', 'Director Marketing');
INSERT INTO EMPLEADOS (id_empleado, id_departamento, id_supervisor, nombre_empleado, email_empleado, rol_empleado) VALUES (SEQ_EMPLEADOS.NEXTVAL, 4, NULL, 'Jefe Soporte', 'sop@qflix.com', 'Director Soporte');
INSERT INTO EMPLEADOS (id_empleado, id_departamento, id_supervisor, nombre_empleado, email_empleado, rol_empleado) VALUES (SEQ_EMPLEADOS.NEXTVAL, 4, 4, 'Moderador 1', 'mod1@qflix.com', 'Moderador');

UPDATE DEPARTAMENTOS SET id_empleado_jefe = 1 WHERE id_departamento = 1;
UPDATE DEPARTAMENTOS SET id_empleado_jefe = 2 WHERE id_departamento = 2;
UPDATE DEPARTAMENTOS SET id_empleado_jefe = 3 WHERE id_departamento = 3;
UPDATE DEPARTAMENTOS SET id_empleado_jefe = 4 WHERE id_departamento = 4;

-- 9. CONTENIDO (40+ registros)
BEGIN
    -- Peliculas (Categoria 1)
    FOR i IN 1..15 LOOP
        INSERT INTO CONTENIDO (id_contenido, id_categoria, id_empleado_publicador, titulo, ano_lanzamiento, duracion_minutos, clasificacion_edad, es_original)
        VALUES (SEQ_CONTENIDO.NEXTVAL, 1, 2, 'Pelicula Ficticia '||i, 2010+i, 120, CASE WHEN MOD(i,2)=0 THEN 'TP' ELSE '+16' END, 1);
    END LOOP;
    
    -- Series (Categoria 2)
    FOR i IN 1..10 LOOP
        INSERT INTO CONTENIDO (id_contenido, id_categoria, id_empleado_publicador, titulo, ano_lanzamiento, duracion_minutos, clasificacion_edad, es_original)
        VALUES (SEQ_CONTENIDO.NEXTVAL, 2, 2, 'Serie Ficticia '||i, 2015+i, NULL, '+13', 1);
    END LOOP;

    -- Documentales (Categoria 3)
    FOR i IN 1..10 LOOP
        INSERT INTO CONTENIDO (id_contenido, id_categoria, id_empleado_publicador, titulo, ano_lanzamiento, duracion_minutos, clasificacion_edad, es_original)
        VALUES (SEQ_CONTENIDO.NEXTVAL, 3, 2, 'Documental Ficticio '||i, 2018+i, 90, 'TP', 0);
    END LOOP;
    
    -- Musica (Categoria 4)
    FOR i IN 1..5 LOOP
        INSERT INTO CONTENIDO (id_contenido, id_categoria, id_empleado_publicador, titulo, ano_lanzamiento, duracion_minutos, clasificacion_edad, es_original)
        VALUES (SEQ_CONTENIDO.NEXTVAL, 4, 2, 'Album Musical '||i, 2020, 45, 'TP', 0);
    END LOOP;
    
    -- Podcasts (Categoria 5)
    FOR i IN 1..5 LOOP
        INSERT INTO CONTENIDO (id_contenido, id_categoria, id_empleado_publicador, titulo, ano_lanzamiento, duracion_minutos, clasificacion_edad, es_original)
        VALUES (SEQ_CONTENIDO.NEXTVAL, 5, 2, 'Podcast Tech '||i, 2023, NULL, '+7', 1);
    END LOOP;
END;
/

-- 10. CONTENIDO_GENERO
BEGIN
    FOR i IN 1..45 LOOP
        -- Asignar genero accion (1) o comedia (2) a todos
        INSERT INTO CONTENIDO_GENERO (id_contenido, id_genero) VALUES (i, CASE WHEN MOD(i,2)=0 THEN 1 ELSE 2 END);
        -- Asignar otro genero
        INSERT INTO CONTENIDO_GENERO (id_contenido, id_genero) VALUES (i, CASE WHEN MOD(i,3)=0 THEN 3 ELSE 4 END);
    END LOOP;
END;
/

-- 11. TEMPORADAS Y 12. EPISODIOS
BEGIN
    -- Para Series (ids 16 a 25)
    FOR c IN 16..25 LOOP
        FOR t IN 1..2 LOOP -- 2 temporadas por serie
            INSERT INTO TEMPORADAS (id_temporada, id_contenido, numero_temporada) VALUES (SEQ_TEMPORADAS.NEXTVAL, c, t);
            -- Guardar el id de temporada para usarlo en episodios
            -- Simularemos asumiendo la secuencia
        END LOOP;
    END LOOP;
    
    -- Insertar episodios para las 20 temporadas (ids 1 a 20)
    FOR t IN 1..20 LOOP
        FOR e IN 1..3 LOOP -- 3 episodios por temporada
            INSERT INTO EPISODIOS (id_episodio, id_temporada, numero_episodio, titulo_episodio, duracion_minutos)
            VALUES (SEQ_EPISODIOS.NEXTVAL, t, e, 'Episodio '||e, 45);
        END LOOP;
    END LOOP;
END;
/

-- 14. REPRODUCCIONES (200+ registros)
BEGIN
    FOR p IN 1..55 LOOP -- Por cada perfil
        FOR r IN 1..4 LOOP -- 4 reproducciones por perfil
            INSERT INTO REPRODUCCIONES (id_reproduccion, id_perfil, id_contenido, id_episodio, fecha_hora_inicio, dispositivo, porcentaje_avance)
            VALUES (SEQ_REPRODUCCIONES.NEXTVAL, p, MOD(p*r, 45)+1, NULL, SYSDATE - MOD(p*r, 30), CASE MOD(p,4) WHEN 0 THEN 'CELULAR' WHEN 1 THEN 'TABLET' WHEN 2 THEN 'TV' ELSE 'COMPUTADOR' END, MOD(p*r*10, 100));
        END LOOP;
    END LOOP;
END;
/

-- 15. CALIFICACIONES (60 registros)
BEGIN
    FOR p IN 1..30 LOOP
        INSERT INTO CALIFICACIONES (id_calificacion, id_perfil, id_contenido, estrellas, resena)
        VALUES (SEQ_CALIFICACIONES.NEXTVAL, p, MOD(p, 45)+1, MOD(p,5)+1, 'Buena pelicula');
        
        INSERT INTO CALIFICACIONES (id_calificacion, id_perfil, id_contenido, estrellas, resena)
        VALUES (SEQ_CALIFICACIONES.NEXTVAL, p, MOD(p+1, 45)+1, MOD(p+2,5)+1, 'Me gusto mucho');
    END LOOP;
END;
/

-- 16. FAVORITOS (40 registros)
BEGIN
    FOR p IN 1..40 LOOP
        INSERT INTO FAVORITOS (id_favorito, id_perfil, id_contenido)
        VALUES (SEQ_FAVORITOS.NEXTVAL, p, MOD(p*2, 45)+1);
    END LOOP;
END;
/

-- 17. REPORTES (10 registros)
BEGIN
    FOR i IN 1..10 LOOP
        INSERT INTO REPORTES (id_reporte, id_perfil, id_contenido, descripcion_reporte, estado_reporte)
        VALUES (SEQ_REPORTES.NEXTVAL, i, i, 'Problemas de audio', CASE WHEN MOD(i,2)=0 THEN 'RESUELTO' ELSE 'PENDIENTE' END);
    END LOOP;
END;
/

-- 18. PAGOS (80 registros)
BEGIN
    FOR u IN 1..35 LOOP
        -- Pago mes actual
        INSERT INTO PAGOS (id_pago, id_usuario, fecha_pago, fecha_vencimiento, monto, metodo_pago, estado_pago)
        VALUES (SEQ_PAGOS.NEXTVAL, u, SYSDATE-5, SYSDATE+25, 24900, 'TARJETA_CREDITO', 'EXITOSO');
        
        -- Pago mes anterior
        INSERT INTO PAGOS (id_pago, id_usuario, fecha_pago, fecha_vencimiento, monto, metodo_pago, estado_pago)
        VALUES (SEQ_PAGOS.NEXTVAL, u, SYSDATE-35, SYSDATE-5, 24900, 'TARJETA_CREDITO', 'EXITOSO');
    END LOOP;
END;
/

COMMIT;
PROMPT 'Datos de prueba insertados correctamente.';
