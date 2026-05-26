-- =====================================================
-- QUINDIOFLIX - SCRIPT DE INSERCION DE DATOS
-- Proyecto Final - Bases de Datos II
-- Cumple volumenes minimos del enunciado (tabla de datos)
-- =====================================================

-- 1. PLANES (minimo 3: Basico, Estandar, Premium)
INSERT INTO PLANES (id_plan, nombre_plan, limite_pantallas, max_perfiles, calidad, precio_mensual) VALUES (SEQ_PLANES.NEXTVAL, 'Basico', 1, 2, 'SD', 14900);
INSERT INTO PLANES (id_plan, nombre_plan, limite_pantallas, max_perfiles, calidad, precio_mensual) VALUES (SEQ_PLANES.NEXTVAL, 'Estandar', 2, 3, 'HD', 24900);
INSERT INTO PLANES (id_plan, nombre_plan, limite_pantallas, max_perfiles, calidad, precio_mensual) VALUES (SEQ_PLANES.NEXTVAL, 'Premium', 4, 5, '4K', 34900);

-- 2. CIUDADES (3 principales + adicionales para reportes)
INSERT INTO CIUDADES (id_ciudad, nombre_ciudad) VALUES (SEQ_CIUDADES.NEXTVAL, 'Bogota');
INSERT INTO CIUDADES (id_ciudad, nombre_ciudad) VALUES (SEQ_CIUDADES.NEXTVAL, 'Medellin');
INSERT INTO CIUDADES (id_ciudad, nombre_ciudad) VALUES (SEQ_CIUDADES.NEXTVAL, 'Armenia');
INSERT INTO CIUDADES (id_ciudad, nombre_ciudad) VALUES (SEQ_CIUDADES.NEXTVAL, 'Cali');
INSERT INTO CIUDADES (id_ciudad, nombre_ciudad) VALUES (SEQ_CIUDADES.NEXTVAL, 'Barranquilla');

-- 3. USUARIOS (minimo 30)
-- Distribuidos en las 3 ciudades principales (1=Bogota, 2=Medellin, 3=Armenia)
-- y en los 3 planes (1=Basico, 2=Estandar, 3=Premium): 10 usuarios por plan
BEGIN
  -- Plan Basico (10 usuarios)
  FOR i IN 1..4 LOOP
    INSERT INTO USUARIOS (id_usuario, id_plan, id_ciudad, id_referidor, nombre_completo, email, contrasena_hash, telefono, fecha_nacimiento, fecha_registro, estado_cuenta)
    VALUES (SEQ_USUARIOS.NEXTVAL, 1, 1, NULL, 'Usuario Bogota Basico '||i, 'usr.bog.bas'||i||'@email.com', 'hash123', '300100'||LPAD(i,4,'0'), TO_DATE('1990-01-01','YYYY-MM-DD')+i, ADD_MONTHS(SYSDATE,-12)-i, 'ACTIVO');
  END LOOP;
  FOR i IN 1..3 LOOP
    INSERT INTO USUARIOS (id_usuario, id_plan, id_ciudad, id_referidor, nombre_completo, email, contrasena_hash, telefono, fecha_nacimiento, fecha_registro, estado_cuenta)
    VALUES (SEQ_USUARIOS.NEXTVAL, 1, 2, 1, 'Usuario Medellin Basico '||i, 'usr.med.bas'||i||'@email.com', 'hash123', '310100'||LPAD(i,4,'0'), TO_DATE('1988-03-15','YYYY-MM-DD')+i, ADD_MONTHS(SYSDATE,-10)-i, 'ACTIVO');
  END LOOP;
  FOR i IN 1..3 LOOP
    INSERT INTO USUARIOS (id_usuario, id_plan, id_ciudad, id_referidor, nombre_completo, email, contrasena_hash, telefono, fecha_nacimiento, fecha_registro, estado_cuenta)
    VALUES (SEQ_USUARIOS.NEXTVAL, 1, 3, 2, 'Usuario Armenia Basico '||i, 'usr.arm.bas'||i||'@email.com', 'hash123', '320100'||LPAD(i,4,'0'), TO_DATE('1995-07-20','YYYY-MM-DD')+i, ADD_MONTHS(SYSDATE,-8)-i, 'ACTIVO');
  END LOOP;

  -- Plan Estandar (10 usuarios)
  FOR i IN 1..3 LOOP
    INSERT INTO USUARIOS (id_usuario, id_plan, id_ciudad, id_referidor, nombre_completo, email, contrasena_hash, telefono, fecha_nacimiento, fecha_registro, estado_cuenta)
    VALUES (SEQ_USUARIOS.NEXTVAL, 2, 1, NULL, 'Usuario Bogota Estandar '||i, 'usr.bog.est'||i||'@email.com', 'hash123', '300200'||LPAD(i,4,'0'), TO_DATE('1992-02-10','YYYY-MM-DD')+i, ADD_MONTHS(SYSDATE,-9)-i, 'ACTIVO');
  END LOOP;
  FOR i IN 1..4 LOOP
    INSERT INTO USUARIOS (id_usuario, id_plan, id_ciudad, id_referidor, nombre_completo, email, contrasena_hash, telefono, fecha_nacimiento, fecha_registro, estado_cuenta)
    VALUES (SEQ_USUARIOS.NEXTVAL, 2, 2, 5, 'Usuario Medellin Estandar '||i, 'usr.med.est'||i||'@email.com', 'hash123', '310200'||LPAD(i,4,'0'), TO_DATE('1987-06-25','YYYY-MM-DD')+i, ADD_MONTHS(SYSDATE,-7)-i, 'ACTIVO');
  END LOOP;
  FOR i IN 1..3 LOOP
    INSERT INTO USUARIOS (id_usuario, id_plan, id_ciudad, id_referidor, nombre_completo, email, contrasena_hash, telefono, fecha_nacimiento, fecha_registro, estado_cuenta)
    VALUES (SEQ_USUARIOS.NEXTVAL, 2, 3, 6, 'Usuario Armenia Estandar '||i, 'usr.arm.est'||i||'@email.com', 'hash123', '320200'||LPAD(i,4,'0'), TO_DATE('1998-11-05','YYYY-MM-DD')+i, ADD_MONTHS(SYSDATE,-6)-i, 'ACTIVO');
  END LOOP;

  -- Plan Premium (10 usuarios)
  FOR i IN 1..3 LOOP
    INSERT INTO USUARIOS (id_usuario, id_plan, id_ciudad, id_referidor, nombre_completo, email, contrasena_hash, telefono, fecha_nacimiento, fecha_registro, estado_cuenta)
    VALUES (SEQ_USUARIOS.NEXTVAL, 3, 1, 10, 'Usuario Bogota Premium '||i, 'usr.bog.pre'||i||'@email.com', 'hash123', '300300'||LPAD(i,4,'0'), TO_DATE('1991-09-12','YYYY-MM-DD')+i, ADD_MONTHS(SYSDATE,-5)-i, 'ACTIVO');
  END LOOP;
  FOR i IN 1..3 LOOP
    INSERT INTO USUARIOS (id_usuario, id_plan, id_ciudad, id_referidor, nombre_completo, email, contrasena_hash, telefono, fecha_nacimiento, fecha_registro, estado_cuenta)
    VALUES (SEQ_USUARIOS.NEXTVAL, 3, 2, 11, 'Usuario Medellin Premium '||i, 'usr.med.pre'||i||'@email.com', 'hash123', '310300'||LPAD(i,4,'0'), TO_DATE('1986-04-18','YYYY-MM-DD')+i, ADD_MONTHS(SYSDATE,-4)-i, 'ACTIVO');
  END LOOP;
  FOR i IN 1..4 LOOP
    INSERT INTO USUARIOS (id_usuario, id_plan, id_ciudad, id_referidor, nombre_completo, email, contrasena_hash, telefono, fecha_nacimiento, fecha_registro, estado_cuenta)
    VALUES (SEQ_USUARIOS.NEXTVAL, 3, 3, 12, 'Usuario Armenia Premium '||i, 'usr.arm.pre'||i||'@email.com', 'hash123', '320300'||LPAD(i,4,'0'), TO_DATE('2000-12-30','YYYY-MM-DD')+i, ADD_MONTHS(SYSDATE,-3)-i, 'ACTIVO');
  END LOOP;
END;
/

-- 4. PERFILES (minimo 50; varios usuarios con multiples perfiles)
BEGIN
  FOR i IN 1..30 LOOP
    INSERT INTO PERFILES (id_perfil, id_usuario, nombre_perfil, avatar, tipo_perfil)
    VALUES (SEQ_PERFILES.NEXTVAL, i, 'Principal '||i, 'avatar_adulto.png', 'ADULTO');
  END LOOP;

  -- 20 usuarios con perfil infantil adicional (total 50 perfiles)
  FOR i IN 1..20 LOOP
    INSERT INTO PERFILES (id_perfil, id_usuario, nombre_perfil, avatar, tipo_perfil)
    VALUES (SEQ_PERFILES.NEXTVAL, i, 'Kids '||i, 'avatar_kids.png', 'INFANTIL');
  END LOOP;
END;
/

-- 5. CATEGORIAS (minimo 5)
INSERT INTO CATEGORIAS (id_categoria, nombre_categoria) VALUES (SEQ_CATEGORIAS.NEXTVAL, 'Peliculas');
INSERT INTO CATEGORIAS (id_categoria, nombre_categoria) VALUES (SEQ_CATEGORIAS.NEXTVAL, 'Series');
INSERT INTO CATEGORIAS (id_categoria, nombre_categoria) VALUES (SEQ_CATEGORIAS.NEXTVAL, 'Documentales');
INSERT INTO CATEGORIAS (id_categoria, nombre_categoria) VALUES (SEQ_CATEGORIAS.NEXTVAL, 'Musica');
INSERT INTO CATEGORIAS (id_categoria, nombre_categoria) VALUES (SEQ_CATEGORIAS.NEXTVAL, 'Podcasts');

-- 6. GENEROS (minimo 8)
INSERT INTO GENEROS (id_genero, nombre_genero) VALUES (SEQ_GENEROS.NEXTVAL, 'Accion');
INSERT INTO GENEROS (id_genero, nombre_genero) VALUES (SEQ_GENEROS.NEXTVAL, 'Comedia');
INSERT INTO GENEROS (id_genero, nombre_genero) VALUES (SEQ_GENEROS.NEXTVAL, 'Drama');
INSERT INTO GENEROS (id_genero, nombre_genero) VALUES (SEQ_GENEROS.NEXTVAL, 'Suspenso');
INSERT INTO GENEROS (id_genero, nombre_genero) VALUES (SEQ_GENEROS.NEXTVAL, 'Romance');
INSERT INTO GENEROS (id_genero, nombre_genero) VALUES (SEQ_GENEROS.NEXTVAL, 'Ciencia Ficcion');
INSERT INTO GENEROS (id_genero, nombre_genero) VALUES (SEQ_GENEROS.NEXTVAL, 'Terror');
INSERT INTO GENEROS (id_genero, nombre_genero) VALUES (SEQ_GENEROS.NEXTVAL, 'Infantil');

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

-- 9. CONTENIDO (minimo 40; distribuido en categorias y generos)
BEGIN
  -- Peliculas (ids 1-15)
  FOR i IN 1..15 LOOP
    INSERT INTO CONTENIDO (id_contenido, id_categoria, id_empleado_publicador, titulo, ano_lanzamiento, duracion_minutos, clasificacion_edad, es_original)
    VALUES (SEQ_CONTENIDO.NEXTVAL, 1, 2, 'Pelicula Ficticia '||i, 2010+i, 120, CASE WHEN MOD(i,2)=0 THEN 'TP' ELSE '+16' END, CASE WHEN MOD(i,2)=0 THEN 1 ELSE 0 END);
  END LOOP;

  -- Series (ids 16-25)
  FOR i IN 1..10 LOOP
    INSERT INTO CONTENIDO (id_contenido, id_categoria, id_empleado_publicador, titulo, ano_lanzamiento, duracion_minutos, clasificacion_edad, es_original)
    VALUES (SEQ_CONTENIDO.NEXTVAL, 2, 2, 'Serie Ficticia '||i, 2015+i, NULL, '+13', 1);
  END LOOP;

  -- Documentales (ids 26-35)
  FOR i IN 1..10 LOOP
    INSERT INTO CONTENIDO (id_contenido, id_categoria, id_empleado_publicador, titulo, ano_lanzamiento, duracion_minutos, clasificacion_edad, es_original)
    VALUES (SEQ_CONTENIDO.NEXTVAL, 3, 2, 'Documental Ficticio '||i, 2018+i, 90, 'TP', 0);
  END LOOP;

  -- Musica (ids 36-40)
  FOR i IN 1..5 LOOP
    INSERT INTO CONTENIDO (id_contenido, id_categoria, id_empleado_publicador, titulo, ano_lanzamiento, duracion_minutos, clasificacion_edad, es_original)
    VALUES (SEQ_CONTENIDO.NEXTVAL, 4, 2, 'Album Musical '||i, 2020, 45, 'TP', 0);
  END LOOP;

  -- Podcasts (ids 41-45)
  FOR i IN 1..5 LOOP
    INSERT INTO CONTENIDO (id_contenido, id_categoria, id_empleado_publicador, titulo, ano_lanzamiento, duracion_minutos, clasificacion_edad, es_original)
    VALUES (SEQ_CONTENIDO.NEXTVAL, 5, 2, 'Podcast Tech '||i, 2023, NULL, '+7', 1);
  END LOOP;
END;
/

-- 10. CONTENIDO_GENERO (distribucion variada de generos)
BEGIN
  FOR i IN 1..45 LOOP
    INSERT INTO CONTENIDO_GENERO (id_contenido, id_genero) VALUES (i, MOD(i-1,8)+1);
    INSERT INTO CONTENIDO_GENERO (id_contenido, id_genero) VALUES (i, MOD(i+2,8)+1);
  END LOOP;
END;
/

-- 11. TEMPORADAS (minimo 15; series y podcasts)
-- Series 16-25: 2 temporadas c/u = 20 | Podcasts 41-45: 1 temporada c/u = 5 | Total = 25
BEGIN
  FOR c IN 16..25 LOOP
    FOR t IN 1..2 LOOP
      INSERT INTO TEMPORADAS (id_temporada, id_contenido, numero_temporada)
      VALUES (SEQ_TEMPORADAS.NEXTVAL, c, t);
    END LOOP;
  END LOOP;

  FOR c IN 41..45 LOOP
    INSERT INTO TEMPORADAS (id_temporada, id_contenido, numero_temporada)
    VALUES (SEQ_TEMPORADAS.NEXTVAL, c, 1);
  END LOOP;
END;
/

-- 12. EPISODIOS (minimo 50; asociados a temporadas 1-25)
BEGIN
  FOR t IN 1..25 LOOP
    FOR e IN 1..3 LOOP
      INSERT INTO EPISODIOS (id_episodio, id_temporada, numero_episodio, titulo_episodio, duracion_minutos)
      VALUES (SEQ_EPISODIOS.NEXTVAL, t, e, 'Episodio '||e||' Temp '||t, 45);
    END LOOP;
  END LOOP;
END;
/

-- Relaciones entre contenidos (modelo ER)
INSERT INTO CONTENIDO_RELACIONADO (id_contenido_origen, id_contenido_destino, tipo_relacion) VALUES (1, 2, 'SECUELA');
INSERT INTO CONTENIDO_RELACIONADO (id_contenido_origen, id_contenido_destino, tipo_relacion) VALUES (16, 17, 'SPIN-OFF');
INSERT INTO CONTENIDO_RELACIONADO (id_contenido_origen, id_contenido_destino, tipo_relacion) VALUES (3, 1, 'PRECUELA');

-- 14. REPRODUCCIONES (minimo 200; variadas por perfil, contenido, dispositivo y fecha)
BEGIN
  FOR p IN 1..50 LOOP
    FOR r IN 1..4 LOOP
      INSERT INTO REPRODUCCIONES (
        id_reproduccion, id_perfil, id_contenido, id_episodio,
        fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance
      ) VALUES (
        SEQ_REPRODUCCIONES.NEXTVAL,
        p,
        CASE
          WHEN r = 1 THEN MOD(p, 45) + 1
          WHEN r = 2 THEN MOD(p + 10, 45) + 1
          ELSE MOD(p * r, 45) + 1
        END,
        CASE WHEN MOD(p + r, 3) = 0 THEN MOD(p + r, 75) + 1 ELSE NULL END,
        SYSTIMESTAMP - NUMTODSINTERVAL(MOD(p * r, 90), 'DAY'),
        SYSTIMESTAMP - NUMTODSINTERVAL(MOD(p * r, 90), 'DAY') + NUMTODSINTERVAL(45, 'MINUTE'),
        CASE MOD(p, 4) WHEN 0 THEN 'CELULAR' WHEN 1 THEN 'TABLET' WHEN 2 THEN 'TV' ELSE 'COMPUTADOR' END,
        CASE WHEN r IN (1, 2) THEN 95 ELSE LEAST(MOD(p * r * 11, 49), 49) END
      );
    END LOOP;
  END LOOP;
END;
/

-- 15. CALIFICACIONES (minimo 60; estrellas 1-5 variadas)
BEGIN
  FOR p IN 1..30 LOOP
    INSERT INTO CALIFICACIONES (id_calificacion, id_perfil, id_contenido, estrellas, resena)
    VALUES (SEQ_CALIFICACIONES.NEXTVAL, p, MOD(p, 45) + 1, MOD(p, 5) + 1, 'Resena perfil '||p);

    INSERT INTO CALIFICACIONES (id_calificacion, id_perfil, id_contenido, estrellas, resena)
    VALUES (SEQ_CALIFICACIONES.NEXTVAL, p, MOD(p + 10, 45) + 1, MOD(p + 2, 5) + 1, 'Segunda calificacion');
  END LOOP;
END;
/

-- 16. FAVORITOS (minimo 40)
BEGIN
  FOR p IN 1..40 LOOP
    INSERT INTO FAVORITOS (id_favorito, id_perfil, id_contenido, fecha_agregado)
    VALUES (SEQ_FAVORITOS.NEXTVAL, p, MOD(p * 3, 45) + 1, SYSDATE - MOD(p, 60));
  END LOOP;
END;
/

-- 17. REPORTES (complemento del modelo ER)
BEGIN
  FOR i IN 1..10 LOOP
    INSERT INTO REPORTES (id_reporte, id_perfil, id_contenido, id_empleado_moderador, descripcion_reporte, estado_reporte, fecha_reporte)
    VALUES (
      SEQ_REPORTES.NEXTVAL, i, MOD(i, 45) + 1,
      CASE WHEN MOD(i,2)=0 THEN 5 ELSE NULL END,
      'Reporte de contenido inapropiado #'||i,
      CASE MOD(i,3) WHEN 0 THEN 'RESUELTO' WHEN 1 THEN 'PENDIENTE' ELSE 'EN_REVISION' END,
      SYSDATE - i
    );
  END LOOP;
END;
/

-- 18. PAGOS (minimo 80; varios meses e incluye fallidos)
BEGIN
  FOR u IN 1..30 LOOP
    DECLARE
      v_monto NUMBER;
    BEGIN
      SELECT precio_mensual INTO v_monto FROM PLANES pl JOIN USUARIOS us ON us.id_plan = pl.id_plan WHERE us.id_usuario = u;

      -- Historial de 3 meses por usuario
      INSERT INTO PAGOS (id_pago, id_usuario, fecha_pago, fecha_vencimiento, monto, metodo_pago, estado_pago)
      VALUES (SEQ_PAGOS.NEXTVAL, u, ADD_MONTHS(TRUNC(SYSDATE), -3), ADD_MONTHS(TRUNC(SYSDATE), -2), v_monto, 'TARJETA_CREDITO', 'EXITOSO');

      INSERT INTO PAGOS (id_pago, id_usuario, fecha_pago, fecha_vencimiento, monto, metodo_pago, estado_pago)
      VALUES (SEQ_PAGOS.NEXTVAL, u, ADD_MONTHS(TRUNC(SYSDATE), -2), ADD_MONTHS(TRUNC(SYSDATE), -1),
              v_monto, CASE MOD(u,3) WHEN 0 THEN 'PSE' WHEN 1 THEN 'NEQUI' ELSE 'TARJETA_DEBITO' END,
              CASE WHEN MOD(u,5)=0 THEN 'FALLIDO' ELSE 'EXITOSO' END);

      INSERT INTO PAGOS (id_pago, id_usuario, fecha_pago, fecha_vencimiento, monto, metodo_pago, estado_pago)
      VALUES (SEQ_PAGOS.NEXTVAL, u, ADD_MONTHS(TRUNC(SYSDATE), -1), TRUNC(SYSDATE) + 29, v_monto, 'DAVIPLATA', 'EXITOSO');
    END;
  END LOOP;

  -- Pagos fallidos adicionales (historial variado)
  FOR u IN 1..20 LOOP
    INSERT INTO PAGOS (id_pago, id_usuario, fecha_pago, fecha_vencimiento, monto, metodo_pago, estado_pago)
    VALUES (SEQ_PAGOS.NEXTVAL, u, ADD_MONTHS(TRUNC(SYSDATE), -4), ADD_MONTHS(TRUNC(SYSDATE), -3), 14900, 'PSE', 'FALLIDO');
  END LOOP;
END;
/

-- Descuentos por referidos (extension del modelo ER)
BEGIN
  FOR i IN 1..10 LOOP
    INSERT INTO DESCUENTOS_REFERIDOS (id_descuento, id_usuario_referidor, id_usuario_referido, porcentaje_descuento, estado)
    VALUES (SEQ_DESCUENTOS_REFERIDOS.NEXTVAL, i, i + 10, 10, CASE WHEN MOD(i,2)=0 THEN 'APLICADO' ELSE 'PENDIENTE' END);
  END LOOP;
END;
/

COMMIT;

-- =====================================================
-- VERIFICACION DE VOLUMENES MINIMOS
-- =====================================================
PROMPT === VERIFICACION DE DATOS (volumenes minimos) ===

SELECT 'PLANES' AS tabla, COUNT(*) AS total, 3 AS minimo_requerido FROM PLANES
UNION ALL SELECT 'USUARIOS', COUNT(*), 30 FROM USUARIOS
UNION ALL SELECT 'PERFILES', COUNT(*), 50 FROM PERFILES
UNION ALL SELECT 'CATEGORIAS', COUNT(*), 5 FROM CATEGORIAS
UNION ALL SELECT 'GENEROS', COUNT(*), 8 FROM GENEROS
UNION ALL SELECT 'CONTENIDO', COUNT(*), 40 FROM CONTENIDO
UNION ALL SELECT 'TEMPORADAS', COUNT(*), 15 FROM TEMPORADAS
UNION ALL SELECT 'EPISODIOS', COUNT(*), 50 FROM EPISODIOS
UNION ALL SELECT 'REPRODUCCIONES', COUNT(*), 200 FROM REPRODUCCIONES
UNION ALL SELECT 'CALIFICACIONES', COUNT(*), 60 FROM CALIFICACIONES
UNION ALL SELECT 'PAGOS', COUNT(*), 80 FROM PAGOS
UNION ALL SELECT 'FAVORITOS', COUNT(*), 40 FROM FAVORITOS
ORDER BY tabla;

PROMPT === DISTRIBUCION USUARIOS (ciudad x plan) ===
SELECT ci.nombre_ciudad, pl.nombre_plan, COUNT(*) AS usuarios
FROM USUARIOS u
JOIN CIUDADES ci ON u.id_ciudad = ci.id_ciudad
JOIN PLANES pl ON u.id_plan = pl.id_plan
WHERE ci.nombre_ciudad IN ('Bogota', 'Medellin', 'Armenia')
GROUP BY ci.nombre_ciudad, pl.nombre_plan
ORDER BY ci.nombre_ciudad, pl.nombre_plan;

PROMPT === PAGOS FALLIDOS ===
SELECT estado_pago, COUNT(*) AS cantidad FROM PAGOS GROUP BY estado_pago;

PROMPT Datos de prueba insertados correctamente.
