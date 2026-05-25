-- =====================================================
-- QUINDIOFLIX - SCRIPT DE TRANSACCIONES (NUCLEO 3)
-- Proyecto Final - Bases de Datos II
-- =====================================================

SET SERVEROUTPUT ON;

-- =====================================================
-- 3.3.1 Especificacion de transacciones (minimo 3)
-- =====================================================

-- a) Transaccion de registro completo (Todo o Nada)
-- Estado inicial: ACTIVA
-- Punto de confirmacion: Despues de crear el pago (COMMIT)
-- Punto de aborto: Si falla cualquier insert (ROLLBACK)
DECLARE
    v_id_usuario NUMBER;
    v_id_perfil NUMBER;
    v_id_pago NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Iniciando transaccion de registro completo...');
    
    -- 1. Insertar Usuario
    v_id_usuario := SEQ_USUARIOS.NEXTVAL;
    INSERT INTO USUARIOS (id_usuario, id_plan, id_ciudad, nombre_completo, email, contrasena_hash, fecha_nacimiento)
    VALUES (v_id_usuario, 1, 1, 'Transaccion Test', 'test.trans@quindioflix.com', 'hash', TO_DATE('1990-01-01', 'YYYY-MM-DD'));
    
    -- 2. Insertar Perfil
    v_id_perfil := SEQ_PERFILES.NEXTVAL;
    INSERT INTO PERFILES (id_perfil, id_usuario, nombre_perfil, tipo_perfil)
    VALUES (v_id_perfil, v_id_usuario, 'Principal', 'ADULTO');
    
    -- 3. Simular un fallo forzado descomentando la siguiente linea:
    -- RAISE_APPLICATION_ERROR(-20001, 'Fallo simulado de la transaccion');
    
    -- 4. Insertar Pago Inicial
    v_id_pago := SEQ_PAGOS.NEXTVAL;
    INSERT INTO PAGOS (id_pago, id_usuario, fecha_pago, fecha_vencimiento, monto, metodo_pago, estado_pago)
    VALUES (v_id_pago, v_id_usuario, SYSDATE, SYSDATE+30, 14900, 'PSE', 'EXITOSO');
    
    -- ESTADO: CONFIRMADA
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Transaccion confirmada. Usuario, perfil y pago registrados.');
EXCEPTION
    WHEN OTHERS THEN
        -- ESTADO: ABORTADA
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Transaccion abortada. Se deshicieron los cambios. Error: ' || SQLERRM);
END;
/

-- b) Transaccion de renovacion mensual masiva (Con SAVEPOINT)
-- Estado: PARCIALMENTE CONFIRMADA en cada iteracion exitosa
DECLARE
    CURSOR c_usuarios_renovacion IS
        SELECT u.id_usuario, pl.precio_mensual
        FROM USUARIOS u
        JOIN PLANES pl ON u.id_plan = pl.id_plan
        WHERE u.estado_cuenta = 'ACTIVO'
          AND TRUNC(u.fecha_ultimo_pago) <= TRUNC(SYSDATE - 30); -- Deben renovar hoy o antes
          
    v_exitosos NUMBER := 0;
    v_fallidos NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Iniciando proceso de renovacion mensual...');
    
    FOR r_usr IN c_usuarios_renovacion LOOP
        -- Establecer un Savepoint al inicio del procesamiento de cada usuario
        SAVEPOINT inicio_usuario;
        
        BEGIN
            -- Insertar pago de renovacion
            INSERT INTO PAGOS (id_pago, id_usuario, fecha_pago, fecha_vencimiento, monto, metodo_pago, estado_pago)
            VALUES (SEQ_PAGOS.NEXTVAL, r_usr.id_usuario, SYSDATE, SYSDATE+30, r_usr.precio_mensual, 'TARJETA_CREDITO', 'EXITOSO');
            
            -- (El trigger actualizara la fecha_ultimo_pago del usuario)
            v_exitosos := v_exitosos + 1;
            
        EXCEPTION
            WHEN OTHERS THEN
                -- Si falla un usuario especifico, solo deshacemos los cambios de este usuario
                ROLLBACK TO inicio_usuario;
                v_fallidos := v_fallidos + 1;
                DBMS_OUTPUT.PUT_LINE('Fallo renovacion para usuario ID: ' || r_usr.id_usuario || ' - Error: ' || SQLERRM);
        END;
    END LOOP;
    
    -- Confirmar todos los exitosos al final
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Renovacion completada. Exitosos: ' || v_exitosos || ', Fallidos: ' || v_fallidos);
END;
/

-- c) Transaccion de eliminacion de cuenta en cascada
-- Elimina desde los detalles hasta el padre. Todo o Nada.
DECLARE
    v_id_usuario_eliminar NUMBER := 35; -- Asumiendo un ID existente
BEGIN
    DBMS_OUTPUT.PUT_LINE('Iniciando eliminacion en cascada del usuario ID ' || v_id_usuario_eliminar);
    
    -- 1. Eliminar datos asociados a perfiles
    DELETE FROM REPRODUCCIONES WHERE id_perfil IN (SELECT id_perfil FROM PERFILES WHERE id_usuario = v_id_usuario_eliminar);
    DELETE FROM CALIFICACIONES WHERE id_perfil IN (SELECT id_perfil FROM PERFILES WHERE id_usuario = v_id_usuario_eliminar);
    DELETE FROM FAVORITOS WHERE id_perfil IN (SELECT id_perfil FROM PERFILES WHERE id_usuario = v_id_usuario_eliminar);
    DELETE FROM REPORTES WHERE id_perfil IN (SELECT id_perfil FROM PERFILES WHERE id_usuario = v_id_usuario_eliminar);
    
    -- 2. Eliminar perfiles
    DELETE FROM PERFILES WHERE id_usuario = v_id_usuario_eliminar;
    
    -- 3. Eliminar datos asociados al usuario
    DELETE FROM PAGOS WHERE id_usuario = v_id_usuario_eliminar;
    DELETE FROM HISTORIAL_PLANES WHERE id_usuario = v_id_usuario_eliminar;
    DELETE FROM DESCUENTOS_REFERIDOS WHERE id_usuario_referidor = v_id_usuario_eliminar OR id_usuario_referido = v_id_usuario_eliminar;
    
    -- 4. Actualizar referidos de este usuario para que no sean huerfanos (evitar error FK)
    UPDATE USUARIOS SET id_referidor = NULL WHERE id_referidor = v_id_usuario_eliminar;
    
    -- 5. Eliminar usuario final
    DELETE FROM USUARIOS WHERE id_usuario = v_id_usuario_eliminar;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Usuario eliminado exitosamente con todos sus datos dependientes.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error durante la eliminacion. Se ha hecho Rollback total. Error: ' || SQLERRM);
END;
/

-- =====================================================
-- 3.3.2 Concurrencia de datos (Escenario documentado)
-- SELECT FOR UPDATE
-- =====================================================

/*
-- ESCENARIO DE PRUEBA:
-- Supongamos que un usuario intenta cambiar de plan en la aplicacion web (Sesion 1),
-- y al mismo tiempo, el proceso batch nocturno intenta suspender la cuenta por falta
-- de pago (Sesion 2).

-- SESION 1 (El usuario cambiando de plan):
BEGIN
    -- Bloquear el registro del usuario para actualizacion
    SELECT id_plan, estado_cuenta 
    INTO v_plan, v_estado 
    FROM USUARIOS 
    WHERE id_usuario = 10 
    FOR UPDATE WAIT 5; -- Esperar maximo 5 segundos si ya esta bloqueado
    
    IF v_estado = 'ACTIVO' THEN
        -- Hacer el cambio de plan y registrar pago
        UPDATE USUARIOS SET id_plan = 2 WHERE id_usuario = 10;
        -- Simular procesamiento
        DBMS_LOCK.SLEEP(3);
        COMMIT; -- Libera el bloqueo
    END IF;
END;

-- SESION 2 (Proceso batch suspendiendo cuentas):
BEGIN
    -- Al intentar actualizar, si la Sesion 1 tiene el bloqueo, 
    -- esta sesion se quedara esperando hasta que la Sesion 1 haga COMMIT o ROLLBACK
    -- (o fallara inmediatamente si usaramos FOR UPDATE NOWAIT)
    SELECT estado_cuenta 
    FROM USUARIOS 
    WHERE id_usuario = 10 
    FOR UPDATE NOWAIT; 
    
    UPDATE USUARIOS SET estado_cuenta = 'SUSPENDIDO' WHERE id_usuario = 10;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -54 THEN
            DBMS_OUTPUT.PUT_LINE('El registro esta siendo modificado por otra transaccion.');
        END IF;
END;
*/
