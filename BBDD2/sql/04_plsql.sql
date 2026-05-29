-- =====================================================
-- QUINDIOFLIX - SCRIPT PL/SQL (NUCLEO 2)
-- Proyecto Final - Bases de Datos II
-- =====================================================

SET SERVEROUTPUT ON;

-- =====================================================
-- 3.2.1 Cursores (minimo 2)
-- =====================================================

-- a) Cursor: Usuarios con suscripcion vencida (> 30 dias)
DECLARE
    CURSOR c_usuarios_morosos IS
        SELECT u.nombre_completo, u.email, pl.nombre_plan, 
               TRUNC(SYSDATE - u.fecha_ultimo_pago) AS dias_mora,
               pl.precio_mensual AS monto_adeudado
        FROM USUARIOS u
        JOIN PLANES pl ON u.id_plan = pl.id_plan
        WHERE u.estado_cuenta = 'ACTIVO' 
          AND u.fecha_ultimo_pago IS NOT NULL
          AND TRUNC(SYSDATE - u.fecha_ultimo_pago) > 30;
          
    v_morosos_encontrados NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- REPORTE DE USUARIOS EN MORA ---');
    FOR r_usuario IN c_usuarios_morosos LOOP
        DBMS_OUTPUT.PUT_LINE('Usuario: ' || r_usuario.nombre_completo || ' | Email: ' || r_usuario.email);
        DBMS_OUTPUT.PUT_LINE('Plan: ' || r_usuario.nombre_plan || ' | Dias Mora: ' || r_usuario.dias_mora || ' | Deuda: $' || r_usuario.monto_adeudado);
        DBMS_OUTPUT.PUT_LINE('-----------------------------------');
        v_morosos_encontrados := v_morosos_encontrados + 1;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Total usuarios en mora: ' || v_morosos_encontrados);
END;
/

-- b) Cursor: Calcular popularidad (reproducciones completas >= 90%)
DECLARE
    CURSOR c_contenido IS
        SELECT id_contenido, titulo FROM CONTENIDO;
        
    v_reproducciones_completas NUMBER;
BEGIN
    FOR r_cont IN c_contenido LOOP
        -- Contar reproducciones completas
        SELECT COUNT(*)
        INTO v_reproducciones_completas
        FROM REPRODUCCIONES
        WHERE id_contenido = r_cont.id_contenido 
          AND porcentaje_avance >= 90;
          
        -- Actualizar popularidad en la tabla
        UPDATE CONTENIDO 
        SET popularidad = v_reproducciones_completas
        WHERE id_contenido = r_cont.id_contenido;
    END LOOP;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Popularidad actualizada para todos los contenidos.');
END;
/

-- =====================================================
-- 3.2.3 Funciones (minimo 2)
-- Se crean antes de los procedimientos para poder usarlas
-- =====================================================

-- a) Funcion: Calcular monto a cobrar con descuentos
CREATE OR REPLACE FUNCTION FN_CALCULAR_MONTO(p_id_usuario IN NUMBER) 
RETURN NUMBER IS
    v_precio_base NUMBER;
    v_meses_antiguedad NUMBER;
    v_monto_final NUMBER;
BEGIN
    -- Obtener precio del plan actual y meses de antiguedad
    SELECT pl.precio_mensual, MONTHS_BETWEEN(SYSDATE, u.fecha_registro)
    INTO v_precio_base, v_meses_antiguedad
    FROM USUARIOS u
    JOIN PLANES pl ON u.id_plan = pl.id_plan
    WHERE u.id_usuario = p_id_usuario;
    
    -- Aplicar descuentos
    IF v_meses_antiguedad >= 24 THEN
        v_monto_final := v_precio_base * 0.85; -- 15% descuento
    ELSIF v_meses_antiguedad >= 12 THEN
        v_monto_final := v_precio_base * 0.90; -- 10% descuento
    ELSE
        v_monto_final := v_precio_base; -- Sin descuento
    END IF;
    
    RETURN v_monto_final;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
END FN_CALCULAR_MONTO;
/

-- b) Funcion: Contenido recomendado basado en el genero mas visto
CREATE OR REPLACE FUNCTION FN_CONTENIDO_RECOMENDADO(p_id_perfil IN NUMBER) 
RETURN VARCHAR2 IS
    v_genero_favorito NUMBER;
    v_titulo_recomendado VARCHAR2(150);
BEGIN
    -- 1. Encontrar el genero mas reproducido por el perfil
    SELECT id_genero INTO v_genero_favorito FROM (
        SELECT cg.id_genero, COUNT(r.id_reproduccion) as total
        FROM REPRODUCCIONES r
        JOIN CONTENIDO_GENERO cg ON r.id_contenido = cg.id_contenido
        WHERE r.id_perfil = p_id_perfil
        GROUP BY cg.id_genero
        ORDER BY total DESC
    ) WHERE ROWNUM = 1;
    
    -- 2. Buscar un contenido de ese genero que no haya visto
    SELECT titulo INTO v_titulo_recomendado FROM (
        SELECT c.titulo
        FROM CONTENIDO c
        JOIN CONTENIDO_GENERO cg ON c.id_contenido = cg.id_contenido
        WHERE cg.id_genero = v_genero_favorito
          AND c.estado = 'ACTIVO'
          AND c.id_contenido NOT IN (
              SELECT id_contenido FROM REPRODUCCIONES WHERE id_perfil = p_id_perfil
          )
        ORDER BY c.popularidad DESC
    ) WHERE ROWNUM = 1;
    
    RETURN v_titulo_recomendado;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Si no hay datos, retornar el titulo mas popular en general
        SELECT titulo INTO v_titulo_recomendado FROM (
            SELECT titulo FROM CONTENIDO WHERE estado = 'ACTIVO' ORDER BY popularidad DESC
        ) WHERE ROWNUM = 1;
        RETURN v_titulo_recomendado;
END FN_CONTENIDO_RECOMENDADO;
/

-- =====================================================
-- 3.2.4 Excepciones Personalizadas (Paquete)
-- =====================================================
CREATE OR REPLACE PACKAGE PKG_EXCEPCIONES AS
    EMAIL_DUPLICADO EXCEPTION;
    PRAGMA EXCEPTION_INIT(EMAIL_DUPLICADO, -20001);
    
    EXCESO_PERFILES EXCEPTION;
    PRAGMA EXCEPTION_INIT(EXCESO_PERFILES, -20002);
END PKG_EXCEPCIONES;
/

-- =====================================================
-- 3.2.2 Procedimientos almacenados (minimo 3)
-- =====================================================

-- a) Procedimiento: Registrar un usuario nuevo
CREATE OR REPLACE PROCEDURE SP_REGISTRAR_USUARIO (
    p_nombre IN VARCHAR2,
    p_email IN VARCHAR2,
    p_pass IN VARCHAR2,
    p_nacimiento IN DATE,
    p_id_ciudad IN NUMBER,
    p_id_plan IN NUMBER
) IS
    v_count NUMBER;
    v_id_usuario NUMBER;
    v_id_perfil NUMBER;
    v_id_pago NUMBER;
    v_precio NUMBER;
BEGIN
    -- Validar si el email existe
    SELECT COUNT(*) INTO v_count FROM USUARIOS WHERE email = p_email;
    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El email ' || p_email || ' ya esta registrado.');
    END IF;
    
    -- Validar si el plan existe y obtener precio (puede lanzar NO_DATA_FOUND)
    SELECT precio_mensual INTO v_precio FROM PLANES WHERE id_plan = p_id_plan;
    
    -- 1. Crear Usuario
    v_id_usuario := SEQ_USUARIOS.NEXTVAL;
    INSERT INTO USUARIOS (id_usuario, id_plan, id_ciudad, nombre_completo, email, contrasena_hash, fecha_nacimiento, estado_cuenta)
    VALUES (v_id_usuario, p_id_plan, p_id_ciudad, p_nombre, p_email, p_pass, p_nacimiento, 'ACTIVO');
    
    -- 2. Crear Perfil predeterminado
    v_id_perfil := SEQ_PERFILES.NEXTVAL;
    INSERT INTO PERFILES (id_perfil, id_usuario, nombre_perfil, tipo_perfil)
    VALUES (v_id_perfil, v_id_usuario, p_nombre, 'ADULTO');
    
    -- 3. Registrar primer pago
    v_id_pago := SEQ_PAGOS.NEXTVAL;
    INSERT INTO PAGOS (id_pago, id_usuario, fecha_pago, fecha_vencimiento, monto, metodo_pago, estado_pago)
    VALUES (v_id_pago, v_id_usuario, SYSDATE, SYSDATE + 30, v_precio, 'TARJETA_CREDITO', 'EXITOSO');
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Usuario registrado exitosamente: ' || p_email);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: El plan seleccionado no existe.');
        ROLLBACK;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al registrar usuario: ' || SQLERRM);
        ROLLBACK;
END SP_REGISTRAR_USUARIO;
/

-- b) Procedimiento: Cambiar de plan
CREATE OR REPLACE PROCEDURE SP_CAMBIAR_PLAN (
    p_id_usuario IN NUMBER,
    p_id_plan_nuevo IN NUMBER
) IS
    v_plan_actual NUMBER;
    v_perfiles_actuales NUMBER;
    v_max_perfiles_nuevo NUMBER;
BEGIN
    -- Obtener plan actual y cantidad de perfiles creados
    SELECT id_plan INTO v_plan_actual FROM USUARIOS WHERE id_usuario = p_id_usuario;
    SELECT COUNT(*) INTO v_perfiles_actuales FROM PERFILES WHERE id_usuario = p_id_usuario;
    
    -- Obtener limites del nuevo plan
    SELECT max_perfiles INTO v_max_perfiles_nuevo FROM PLANES WHERE id_plan = p_id_plan_nuevo;
    
    -- Validar que no tenga mas perfiles que los permitidos por el nuevo plan
    IF v_perfiles_actuales > v_max_perfiles_nuevo THEN
        RAISE_APPLICATION_ERROR(-20002, 'No se puede cambiar al plan. El usuario tiene ' || 
                                       v_perfiles_actuales || ' perfiles, y el nuevo plan permite maximo ' || v_max_perfiles_nuevo);
    END IF;
    
    -- Actualizar plan
    UPDATE USUARIOS SET id_plan = p_id_plan_nuevo WHERE id_usuario = p_id_usuario;
    
    -- Registrar en historial
    INSERT INTO HISTORIAL_PLANES (id_historial, id_usuario, id_plan_anterior, id_plan_nuevo, fecha_cambio)
    VALUES (SEQ_HISTORIAL_PLANES.NEXTVAL, p_id_usuario, v_plan_actual, p_id_plan_nuevo, SYSDATE);
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Plan actualizado exitosamente.');
END SP_CAMBIAR_PLAN;
/

-- c) Procedimiento: Reporte de consumo
CREATE OR REPLACE PROCEDURE SP_REPORTE_CONSUMO (
    p_id_usuario IN NUMBER,
    p_fecha_inicio IN DATE,
    p_fecha_fin IN DATE
) IS
    CURSOR c_consumo IS
        SELECT p.nombre_perfil, ca.nombre_categoria, COUNT(r.id_reproduccion) as num_rep, SUM(NVL(c.duracion_minutos, 45) * r.porcentaje_avance / 100) as minutos_estimados
        FROM PERFILES p
        JOIN REPRODUCCIONES r ON p.id_perfil = r.id_perfil
        JOIN CONTENIDO c ON r.id_contenido = c.id_contenido
        JOIN CATEGORIAS ca ON c.id_categoria = ca.id_categoria
        WHERE p.id_usuario = p_id_usuario
          AND r.fecha_hora_inicio BETWEEN p_fecha_inicio AND p_fecha_fin
        GROUP BY p.nombre_perfil, ca.nombre_categoria
        ORDER BY p.nombre_perfil, minutos_estimados DESC;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- REPORTE DE CONSUMO ---');
    DBMS_OUTPUT.PUT_LINE('Usuario ID: ' || p_id_usuario);
    DBMS_OUTPUT.PUT_LINE('Periodo: ' || TO_CHAR(p_fecha_inicio, 'DD/MM/YYYY') || ' - ' || TO_CHAR(p_fecha_fin, 'DD/MM/YYYY'));
    
    FOR r IN c_consumo LOOP
        DBMS_OUTPUT.PUT_LINE('Perfil: ' || r.nombre_perfil || ' | Categoria: ' || r.nombre_categoria || 
                             ' | Reproducciones: ' || r.num_rep || ' | Minutos: ' || ROUND(r.minutos_estimados));
    END LOOP;
END SP_REPORTE_CONSUMO;
/

-- =====================================================
-- 3.2.5 Disparadores (minimo 4)
-- =====================================================

BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER TRG_VERIFICAR_CUENTA_ACTIVA';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- a) Trigger: El candado del streaming (trg_validar_cuenta_reproduccion)
CREATE OR REPLACE TRIGGER trg_validar_cuenta_reproduccion
BEFORE INSERT ON REPRODUCCIONES
FOR EACH ROW
DECLARE
    v_estado VARCHAR2(20);
BEGIN
    SELECT u.estado_cuenta INTO v_estado
    FROM USUARIOS u
    JOIN PERFILES p ON u.id_usuario = p.id_usuario
    WHERE p.id_perfil = :NEW.id_perfil;
    
    IF v_estado <> 'ACTIVO' THEN
        RAISE_APPLICATION_ERROR(-20003, 'No se puede reproducir contenido. La cuenta se encuentra en estado: ' || v_estado);
    END IF;
END;
/

-- b) Trigger: Limitar numero de perfiles segun el plan
CREATE OR REPLACE TRIGGER TRG_LIMITE_PERFILES
BEFORE INSERT ON PERFILES
FOR EACH ROW
DECLARE
    v_max_perfiles NUMBER;
    v_perfiles_actuales NUMBER;
BEGIN
    -- Obtener maximo de perfiles del plan del usuario
    SELECT pl.max_perfiles INTO v_max_perfiles
    FROM USUARIOS u
    JOIN PLANES pl ON u.id_plan = pl.id_plan
    WHERE u.id_usuario = :NEW.id_usuario;
    
    -- Contar perfiles actuales
    SELECT COUNT(*) INTO v_perfiles_actuales
    FROM PERFILES
    WHERE id_usuario = :NEW.id_usuario;
    
    IF v_perfiles_actuales >= v_max_perfiles THEN
        RAISE_APPLICATION_ERROR(-20004, 'Limite de perfiles alcanzado para su plan (' || v_max_perfiles || ').');
    END IF;
END;
/

-- c) Trigger: El guardian de las resenas (trg_validar_calificacion)
-- Cruza la calificacion que se intenta insertar con el historial de reproducciones
-- y la duracion del contenido antes de permitir la accion.
CREATE OR REPLACE TRIGGER trg_validar_calificacion
BEFORE INSERT ON CALIFICACIONES
FOR EACH ROW
DECLARE
    v_duracion_total    NUMBER;
    v_minutos_vistos    NUMBER;
    v_minimo_requerido  NUMBER;
BEGIN
    -- Duracion total del titulo (pelicula, documental, musica; series usan valor por defecto)
    SELECT NVL(c.duracion_minutos, 45)
    INTO v_duracion_total
    FROM CONTENIDO c
    WHERE c.id_contenido = :NEW.id_contenido;

    -- Minutos equivalentes vistos = JOIN entre reproduccion e intento de calificacion
    SELECT NVL(MAX(
        (r.porcentaje_avance / 100) * NVL(c.duracion_minutos, 45)
    ), 0)
    INTO v_minutos_vistos
    FROM REPRODUCCIONES r
    INNER JOIN CONTENIDO c ON c.id_contenido = r.id_contenido
    WHERE r.id_perfil = :NEW.id_perfil
      AND r.id_contenido = :NEW.id_contenido;

    v_minimo_requerido := v_duracion_total * 0.5;

    IF v_minutos_vistos < v_minimo_requerido THEN
        RAISE_APPLICATION_ERROR(-20005,
            'Error: Debes ver al menos el 50% del contenido para poder calificarlo. ' ||
            'Minutos vistos: ' || ROUND(v_minutos_vistos, 1) ||
            ' / requeridos: ' || ROUND(v_minimo_requerido, 1));
    END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER TRG_PAGO_EXITOSO';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- d) Trigger: El reactivador automatico (trg_actualizar_estado_cuenta)
CREATE OR REPLACE TRIGGER trg_actualizar_estado_cuenta
AFTER INSERT ON PAGOS
FOR EACH ROW
WHEN (NEW.estado_pago = 'EXITOSO')
BEGIN
    UPDATE USUARIOS
    SET estado_cuenta = 'ACTIVO',
        fecha_ultimo_pago = :NEW.fecha_pago
    WHERE id_usuario = :NEW.id_usuario;
END;
/
