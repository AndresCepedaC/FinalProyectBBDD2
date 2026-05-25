-- =====================================================
-- QUINDIOFLIX - SCRIPT DE CREACION DE TABLAS
-- Proyecto Final - Bases de Datos II
-- Universidad del Quindio
-- =====================================================
-- Este script crea toda la estructura de la base de datos
-- para la plataforma de streaming QuindioFlix.
-- Incluye: secuencias, tablas, restricciones, y comentarios.
-- =====================================================

-- =====================================================
-- SECCION 0: LIMPIEZA PREVIA
-- Eliminar tablas en orden inverso de dependencias
-- para evitar conflictos con foreign keys.
-- =====================================================

-- Desactivar restricciones temporalmente para limpieza
BEGIN
    FOR c IN (SELECT table_name, constraint_name 
              FROM user_constraints 
              WHERE constraint_type = 'R') LOOP
        EXECUTE IMMEDIATE 'ALTER TABLE ' || c.table_name || 
                          ' DISABLE CONSTRAINT ' || c.constraint_name;
    END LOOP;
END;
/

-- Eliminar tablas si existen
BEGIN
    FOR t IN (SELECT table_name FROM user_tables WHERE table_name IN (
        'DESCUENTOS_REFERIDOS', 'HISTORIAL_PLANES', 'PAGOS', 'REPORTES',
        'FAVORITOS', 'CALIFICACIONES', 'REPRODUCCIONES', 'CONTENIDO_RELACIONADO',
        'EPISODIOS', 'TEMPORADAS', 'CONTENIDO_GENERO', 'CONTENIDO',
        'EMPLEADOS', 'DEPARTAMENTOS', 'PERFILES', 'USUARIOS',
        'GENEROS', 'CATEGORIAS', 'CIUDADES', 'PLANES'
    )) LOOP
        EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS';
    END LOOP;
END;
/

-- Eliminar secuencias si existen
BEGIN
    FOR s IN (SELECT sequence_name FROM user_sequences WHERE sequence_name IN (
        'SEQ_PLANES', 'SEQ_CIUDADES', 'SEQ_USUARIOS', 'SEQ_PERFILES',
        'SEQ_CATEGORIAS', 'SEQ_GENEROS', 'SEQ_CONTENIDO', 'SEQ_TEMPORADAS',
        'SEQ_EPISODIOS', 'SEQ_DEPARTAMENTOS', 'SEQ_EMPLEADOS',
        'SEQ_REPRODUCCIONES', 'SEQ_CALIFICACIONES', 'SEQ_FAVORITOS',
        'SEQ_REPORTES', 'SEQ_PAGOS', 'SEQ_HISTORIAL_PLANES',
        'SEQ_DESCUENTOS_REFERIDOS'
    )) LOOP
        EXECUTE IMMEDIATE 'DROP SEQUENCE ' || s.sequence_name;
    END LOOP;
END;
/

-- =====================================================
-- SECCION 1: SECUENCIAS
-- Oracle no tiene AUTO_INCREMENT nativo (pre-12c).
-- Usamos secuencias para generar IDs unicos.
-- =====================================================

CREATE SEQUENCE SEQ_PLANES START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_CIUDADES START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_USUARIOS START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_PERFILES START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_CATEGORIAS START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_GENEROS START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_CONTENIDO START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_TEMPORADAS START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_EPISODIOS START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_DEPARTAMENTOS START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_EMPLEADOS START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_REPRODUCCIONES START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_CALIFICACIONES START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_FAVORITOS START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_REPORTES START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_PAGOS START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_HISTORIAL_PLANES START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_DESCUENTOS_REFERIDOS START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

-- =====================================================
-- SECCION 2: CREACION DE TABLAS
-- Las tablas se crean en orden de dependencias:
-- primero las tablas sin FK, luego las dependientes.
-- =====================================================

-- =====================================================
-- TABLA 1: PLANES
-- Almacena los planes de suscripcion disponibles.
-- Basico, Estandar y Premium con diferentes limites.
-- =====================================================
CREATE TABLE PLANES (
    id_plan             NUMBER          CONSTRAINT planes_pk PRIMARY KEY,
    nombre_plan         VARCHAR2(50)    CONSTRAINT planes_nombre_nn NOT NULL,
    limite_pantallas    NUMBER          CONSTRAINT planes_pantallas_nn NOT NULL,
    max_perfiles        NUMBER          CONSTRAINT planes_maxperf_nn NOT NULL,
    calidad             VARCHAR2(10)    CONSTRAINT planes_calidad_nn NOT NULL,
    precio_mensual      NUMBER(10,2)    CONSTRAINT planes_precio_nn NOT NULL,
    -- Restricciones de dominio
    CONSTRAINT planes_nombre_uk UNIQUE (nombre_plan),
    CONSTRAINT planes_calidad_ck CHECK (calidad IN ('SD', 'HD', '4K')),
    CONSTRAINT planes_precio_ck CHECK (precio_mensual > 0),
    CONSTRAINT planes_pantallas_ck CHECK (limite_pantallas > 0),
    CONSTRAINT planes_maxperf_ck CHECK (max_perfiles > 0)
);

COMMENT ON TABLE PLANES IS 'Planes de suscripcion disponibles en QuindioFlix (Basico, Estandar, Premium)';
COMMENT ON COLUMN PLANES.id_plan IS 'Identificador unico del plan (PK)';
COMMENT ON COLUMN PLANES.nombre_plan IS 'Nombre comercial del plan (Basico, Estandar, Premium)';
COMMENT ON COLUMN PLANES.limite_pantallas IS 'Numero maximo de pantallas simultaneas permitidas';
COMMENT ON COLUMN PLANES.max_perfiles IS 'Numero maximo de perfiles que puede tener la cuenta';
COMMENT ON COLUMN PLANES.calidad IS 'Calidad maxima de streaming: SD, HD o 4K';
COMMENT ON COLUMN PLANES.precio_mensual IS 'Precio mensual del plan en pesos colombianos';

-- =====================================================
-- TABLA 2: CIUDADES
-- Catalogo de ciudades donde residen los usuarios.
-- Permite reportes de consumo y financieros por ciudad.
-- =====================================================
CREATE TABLE CIUDADES (
    id_ciudad       NUMBER          CONSTRAINT ciudades_pk PRIMARY KEY,
    nombre_ciudad   VARCHAR2(100)   CONSTRAINT ciudades_nombre_nn NOT NULL,
    CONSTRAINT ciudades_nombre_uk UNIQUE (nombre_ciudad)
);

COMMENT ON TABLE CIUDADES IS 'Catalogo de ciudades de residencia de los usuarios de QuindioFlix';
COMMENT ON COLUMN CIUDADES.id_ciudad IS 'Identificador unico de la ciudad (PK)';
COMMENT ON COLUMN CIUDADES.nombre_ciudad IS 'Nombre de la ciudad (unico)';

-- =====================================================
-- TABLA 3: USUARIOS
-- Usuarios registrados en la plataforma.
-- Incluye datos personales, plan, estado y referidos.
-- Relacion reflexiva: un usuario puede referir a otro.
-- =====================================================
CREATE TABLE USUARIOS (
    id_usuario          NUMBER          CONSTRAINT usuarios_pk PRIMARY KEY,
    id_plan             NUMBER          CONSTRAINT usuarios_plan_nn NOT NULL,
    id_ciudad           NUMBER          CONSTRAINT usuarios_ciudad_nn NOT NULL,
    id_referidor        NUMBER,         -- Nullable: no todos tienen referidor
    nombre_completo     VARCHAR2(150)   CONSTRAINT usuarios_nombre_nn NOT NULL,
    email               VARCHAR2(100)   CONSTRAINT usuarios_email_nn NOT NULL,
    contrasena_hash     VARCHAR2(255)   CONSTRAINT usuarios_pass_nn NOT NULL,
    telefono            VARCHAR2(20),
    fecha_nacimiento    DATE            CONSTRAINT usuarios_fechanac_nn NOT NULL,
    fecha_registro      DATE            DEFAULT SYSDATE,
    estado_cuenta       VARCHAR2(20)    DEFAULT 'ACTIVO',
    fecha_ultimo_pago   DATE,           -- Se actualiza via trigger en PAGOS
    -- Restricciones
    CONSTRAINT usuarios_email_uk UNIQUE (email),
    CONSTRAINT usuarios_estado_ck CHECK (estado_cuenta IN ('ACTIVO', 'INACTIVO', 'SUSPENDIDO')),
    -- Foreign Keys
    CONSTRAINT fk_usu_plan FOREIGN KEY (id_plan) REFERENCES PLANES(id_plan),
    CONSTRAINT fk_usu_ciudad FOREIGN KEY (id_ciudad) REFERENCES CIUDADES(id_ciudad),
    CONSTRAINT fk_usu_referidor FOREIGN KEY (id_referidor) REFERENCES USUARIOS(id_usuario)
);

COMMENT ON TABLE USUARIOS IS 'Usuarios registrados en QuindioFlix con sus datos personales y suscripcion';
COMMENT ON COLUMN USUARIOS.id_usuario IS 'Identificador unico del usuario (PK)';
COMMENT ON COLUMN USUARIOS.id_plan IS 'Plan de suscripcion actual del usuario (FK a PLANES)';
COMMENT ON COLUMN USUARIOS.id_ciudad IS 'Ciudad de residencia del usuario (FK a CIUDADES)';
COMMENT ON COLUMN USUARIOS.id_referidor IS 'Usuario que refirio a este usuario (FK reflexiva a USUARIOS, nullable)';
COMMENT ON COLUMN USUARIOS.nombre_completo IS 'Nombre completo del usuario';
COMMENT ON COLUMN USUARIOS.email IS 'Correo electronico unico del usuario (usado para login)';
COMMENT ON COLUMN USUARIOS.contrasena_hash IS 'Hash de la contrasena del usuario (seguridad)';
COMMENT ON COLUMN USUARIOS.telefono IS 'Numero de telefono del usuario (opcional)';
COMMENT ON COLUMN USUARIOS.fecha_nacimiento IS 'Fecha de nacimiento del usuario';
COMMENT ON COLUMN USUARIOS.fecha_registro IS 'Fecha en que el usuario se registro en la plataforma';
COMMENT ON COLUMN USUARIOS.estado_cuenta IS 'Estado actual de la cuenta: ACTIVO, INACTIVO o SUSPENDIDO';
COMMENT ON COLUMN USUARIOS.fecha_ultimo_pago IS 'Fecha del ultimo pago exitoso (actualizada por trigger)';

-- =====================================================
-- TABLA 4: PERFILES
-- Perfiles dentro de una cuenta de usuario.
-- Maximo segun plan: Basico=2, Estandar=3, Premium=5.
-- Tipos: ADULTO (acceso total) o INFANTIL (restriccion).
-- =====================================================
CREATE TABLE PERFILES (
    id_perfil       NUMBER          CONSTRAINT perfiles_pk PRIMARY KEY,
    id_usuario      NUMBER          CONSTRAINT perfiles_usuario_nn NOT NULL,
    nombre_perfil   VARCHAR2(50)    CONSTRAINT perfiles_nombre_nn NOT NULL,
    avatar          VARCHAR2(255),
    tipo_perfil     VARCHAR2(20)    CONSTRAINT perfiles_tipo_nn NOT NULL,
    fecha_creacion  DATE            DEFAULT SYSDATE,
    -- Restricciones
    CONSTRAINT perfiles_tipo_ck CHECK (tipo_perfil IN ('ADULTO', 'INFANTIL')),
    -- Foreign Keys
    CONSTRAINT fk_perf_usuario FOREIGN KEY (id_usuario) REFERENCES USUARIOS(id_usuario)
);

COMMENT ON TABLE PERFILES IS 'Perfiles de usuario dentro de una cuenta. Cada cuenta puede tener multiples perfiles';
COMMENT ON COLUMN PERFILES.id_perfil IS 'Identificador unico del perfil (PK)';
COMMENT ON COLUMN PERFILES.id_usuario IS 'Usuario propietario del perfil (FK a USUARIOS)';
COMMENT ON COLUMN PERFILES.nombre_perfil IS 'Nombre visible del perfil';
COMMENT ON COLUMN PERFILES.avatar IS 'URL o ruta del avatar del perfil';
COMMENT ON COLUMN PERFILES.tipo_perfil IS 'Tipo de perfil: ADULTO (acceso completo) o INFANTIL (contenido restringido TP, +7, +13)';
COMMENT ON COLUMN PERFILES.fecha_creacion IS 'Fecha de creacion del perfil';

-- =====================================================
-- TABLA 5: CATEGORIAS
-- Tipos de contenido: Peliculas, Series, Documentales,
-- Musica, Podcasts.
-- =====================================================
CREATE TABLE CATEGORIAS (
    id_categoria        NUMBER          CONSTRAINT categorias_pk PRIMARY KEY,
    nombre_categoria    VARCHAR2(50)    CONSTRAINT categorias_nombre_nn NOT NULL,
    CONSTRAINT categorias_nombre_uk UNIQUE (nombre_categoria)
);

COMMENT ON TABLE CATEGORIAS IS 'Categorias de contenido: Peliculas, Series, Documentales, Musica, Podcasts';
COMMENT ON COLUMN CATEGORIAS.id_categoria IS 'Identificador unico de la categoria (PK)';
COMMENT ON COLUMN CATEGORIAS.nombre_categoria IS 'Nombre de la categoria (unico)';

-- =====================================================
-- TABLA 6: GENEROS
-- Generos del contenido: Accion, Comedia, Drama, etc.
-- Un contenido puede pertenecer a multiples generos
-- (relacion M:N mediante CONTENIDO_GENERO).
-- =====================================================
CREATE TABLE GENEROS (
    id_genero       NUMBER          CONSTRAINT generos_pk PRIMARY KEY,
    nombre_genero   VARCHAR2(50)    CONSTRAINT generos_nombre_nn NOT NULL,
    CONSTRAINT generos_nombre_uk UNIQUE (nombre_genero)
);

COMMENT ON TABLE GENEROS IS 'Generos del contenido multimedia (Accion, Comedia, Drama, etc.)';
COMMENT ON COLUMN GENEROS.id_genero IS 'Identificador unico del genero (PK)';
COMMENT ON COLUMN GENEROS.nombre_genero IS 'Nombre del genero (unico)';

-- =====================================================
-- TABLA 7: DEPARTAMENTOS
-- Departamentos de la empresa QuindioFlix.
-- NOTA: id_empleado_jefe es nullable para resolver la
-- dependencia circular con EMPLEADOS. Se actualiza
-- despues de insertar los empleados.
-- =====================================================
CREATE TABLE DEPARTAMENTOS (
    id_departamento         NUMBER          CONSTRAINT departamentos_pk PRIMARY KEY,
    nombre_departamento     VARCHAR2(50)    CONSTRAINT depart_nombre_nn NOT NULL,
    id_empleado_jefe        NUMBER,         -- Nullable: se actualiza despues de crear empleados
    CONSTRAINT departamentos_nombre_uk UNIQUE (nombre_departamento)
);

COMMENT ON TABLE DEPARTAMENTOS IS 'Departamentos de la empresa: Tecnologia, Contenido, Marketing, Soporte, Finanzas';
COMMENT ON COLUMN DEPARTAMENTOS.id_departamento IS 'Identificador unico del departamento (PK)';
COMMENT ON COLUMN DEPARTAMENTOS.nombre_departamento IS 'Nombre del departamento (unico)';
COMMENT ON COLUMN DEPARTAMENTOS.id_empleado_jefe IS 'Empleado que es jefe del departamento (FK a EMPLEADOS, nullable)';

-- =====================================================
-- TABLA 8: EMPLEADOS
-- Empleados de QuindioFlix organizados por departamento.
-- Relacion reflexiva: un empleado puede supervisar a otros.
-- Los de Contenido publican contenido; los de Soporte
-- resuelven reportes.
-- =====================================================
CREATE TABLE EMPLEADOS (
    id_empleado         NUMBER          CONSTRAINT empleados_pk PRIMARY KEY,
    id_departamento     NUMBER          CONSTRAINT empleados_depto_nn NOT NULL,
    id_supervisor       NUMBER,         -- Nullable: jefes de departamento no tienen supervisor
    nombre_empleado     VARCHAR2(100)   CONSTRAINT empleados_nombre_nn NOT NULL,
    email_empleado      VARCHAR2(100),
    rol_empleado        VARCHAR2(60)    CONSTRAINT empleados_rol_nn NOT NULL,
    fecha_contratacion  DATE            DEFAULT SYSDATE,
    -- Restricciones
    CONSTRAINT empleados_email_uk UNIQUE (email_empleado),
    -- Foreign Keys
    CONSTRAINT fk_emp_depto FOREIGN KEY (id_departamento) REFERENCES DEPARTAMENTOS(id_departamento),
    CONSTRAINT fk_emp_supervisor FOREIGN KEY (id_supervisor) REFERENCES EMPLEADOS(id_empleado)
);

COMMENT ON TABLE EMPLEADOS IS 'Empleados de QuindioFlix con jerarquia de supervision por departamento';
COMMENT ON COLUMN EMPLEADOS.id_empleado IS 'Identificador unico del empleado (PK)';
COMMENT ON COLUMN EMPLEADOS.id_departamento IS 'Departamento al que pertenece el empleado (FK a DEPARTAMENTOS)';
COMMENT ON COLUMN EMPLEADOS.id_supervisor IS 'Supervisor directo del empleado (FK reflexiva a EMPLEADOS, nullable para jefes)';
COMMENT ON COLUMN EMPLEADOS.nombre_empleado IS 'Nombre completo del empleado';
COMMENT ON COLUMN EMPLEADOS.email_empleado IS 'Correo electronico corporativo del empleado';
COMMENT ON COLUMN EMPLEADOS.rol_empleado IS 'Rol del empleado dentro del departamento';
COMMENT ON COLUMN EMPLEADOS.fecha_contratacion IS 'Fecha de contratacion del empleado';

-- Ahora agregar la FK de DEPARTAMENTOS a EMPLEADOS (resuelve dependencia circular)
ALTER TABLE DEPARTAMENTOS 
    ADD CONSTRAINT fk_depto_jefe FOREIGN KEY (id_empleado_jefe) REFERENCES EMPLEADOS(id_empleado);

-- =====================================================
-- TABLA 9: CONTENIDO
-- Contenido multimedia del catalogo de QuindioFlix.
-- Incluye peliculas, series, documentales, musica y
-- podcasts. Las series y podcasts tienen temporadas
-- y episodios asociados.
-- =====================================================
CREATE TABLE CONTENIDO (
    id_contenido            NUMBER          CONSTRAINT contenido_pk PRIMARY KEY,
    id_categoria            NUMBER          CONSTRAINT contenido_cat_nn NOT NULL,
    id_empleado_publicador  NUMBER,         -- Empleado que publico el contenido
    titulo                  VARCHAR2(150)   CONSTRAINT contenido_titulo_nn NOT NULL,
    ano_lanzamiento         NUMBER(4)       CONSTRAINT contenido_ano_nn NOT NULL,
    duracion_minutos        NUMBER,         -- Para peliculas/docs/musica. NULL para series/podcasts
    sinopsis                VARCHAR2(2000),
    clasificacion_edad      VARCHAR2(10)    CONSTRAINT contenido_clasif_nn NOT NULL,
    fecha_agregado          DATE            DEFAULT SYSDATE,
    es_original             NUMBER(1)       DEFAULT 0,
    popularidad             NUMBER          DEFAULT 0,
    estado                  VARCHAR2(20)    DEFAULT 'ACTIVO',
    -- Restricciones de dominio
    CONSTRAINT contenido_clasif_ck CHECK (clasificacion_edad IN ('TP', '+7', '+13', '+16', '+18')),
    CONSTRAINT contenido_original_ck CHECK (es_original IN (0, 1)),
    CONSTRAINT contenido_estado_ck CHECK (estado IN ('ACTIVO', 'INACTIVO', 'EN_REVISION')),
    CONSTRAINT contenido_ano_ck CHECK (ano_lanzamiento BETWEEN 1900 AND 2100),
    -- Foreign Keys
    CONSTRAINT fk_cont_categoria FOREIGN KEY (id_categoria) REFERENCES CATEGORIAS(id_categoria),
    CONSTRAINT fk_cont_empleado FOREIGN KEY (id_empleado_publicador) REFERENCES EMPLEADOS(id_empleado)
);

COMMENT ON TABLE CONTENIDO IS 'Catalogo de contenido multimedia de QuindioFlix (peliculas, series, documentales, musica, podcasts)';
COMMENT ON COLUMN CONTENIDO.id_contenido IS 'Identificador unico del contenido (PK)';
COMMENT ON COLUMN CONTENIDO.id_categoria IS 'Categoria del contenido: Pelicula, Serie, Documental, Musica, Podcast (FK a CATEGORIAS)';
COMMENT ON COLUMN CONTENIDO.id_empleado_publicador IS 'Empleado de Contenido que publico este titulo (FK a EMPLEADOS)';
COMMENT ON COLUMN CONTENIDO.titulo IS 'Titulo del contenido';
COMMENT ON COLUMN CONTENIDO.ano_lanzamiento IS 'Ano de lanzamiento original del contenido';
COMMENT ON COLUMN CONTENIDO.duracion_minutos IS 'Duracion en minutos (para peliculas, docs, musica). NULL para series y podcasts';
COMMENT ON COLUMN CONTENIDO.sinopsis IS 'Descripcion o sinopsis del contenido';
COMMENT ON COLUMN CONTENIDO.clasificacion_edad IS 'Clasificacion de edad: TP (Todo Publico), +7, +13, +16, +18';
COMMENT ON COLUMN CONTENIDO.fecha_agregado IS 'Fecha en que el contenido fue agregado al catalogo';
COMMENT ON COLUMN CONTENIDO.es_original IS 'Indica si es una produccion original de QuindioFlix (1=Si, 0=No)';
COMMENT ON COLUMN CONTENIDO.popularidad IS 'Indice de popularidad calculado por cursor (reproducciones completas)';
COMMENT ON COLUMN CONTENIDO.estado IS 'Estado del contenido: ACTIVO, INACTIVO o EN_REVISION';

-- =====================================================
-- TABLA 10: CONTENIDO_GENERO (Tabla Intermedia M:N)
-- Relacion muchos a muchos entre CONTENIDO y GENEROS.
-- Un contenido puede tener multiples generos y un
-- genero puede aplicar a multiples contenidos.
-- =====================================================
CREATE TABLE CONTENIDO_GENERO (
    id_contenido    NUMBER  CONSTRAINT cg_contenido_nn NOT NULL,
    id_genero       NUMBER  CONSTRAINT cg_genero_nn NOT NULL,
    -- PK compuesta
    CONSTRAINT contenido_genero_pk PRIMARY KEY (id_contenido, id_genero),
    -- Foreign Keys
    CONSTRAINT fk_cg_contenido FOREIGN KEY (id_contenido) REFERENCES CONTENIDO(id_contenido),
    CONSTRAINT fk_cg_genero FOREIGN KEY (id_genero) REFERENCES GENEROS(id_genero)
);

COMMENT ON TABLE CONTENIDO_GENERO IS 'Tabla intermedia M:N que asocia contenido con generos (un contenido puede tener multiples generos)';
COMMENT ON COLUMN CONTENIDO_GENERO.id_contenido IS 'Referencia al contenido (PK, FK a CONTENIDO)';
COMMENT ON COLUMN CONTENIDO_GENERO.id_genero IS 'Referencia al genero (PK, FK a GENEROS)';

-- =====================================================
-- TABLA 11: TEMPORADAS
-- Temporadas de series y podcasts.
-- Las peliculas, documentales y musica NO tienen temporadas.
-- =====================================================
CREATE TABLE TEMPORADAS (
    id_temporada        NUMBER  CONSTRAINT temporadas_pk PRIMARY KEY,
    id_contenido        NUMBER  CONSTRAINT temporadas_cont_nn NOT NULL,
    numero_temporada    NUMBER  CONSTRAINT temporadas_num_nn NOT NULL,
    -- Restriccion: no puede haber dos temporadas con el mismo numero para un contenido
    CONSTRAINT temporadas_cont_num_uk UNIQUE (id_contenido, numero_temporada),
    CONSTRAINT temporadas_num_ck CHECK (numero_temporada > 0),
    -- Foreign Keys
    CONSTRAINT fk_temp_contenido FOREIGN KEY (id_contenido) REFERENCES CONTENIDO(id_contenido)
);

COMMENT ON TABLE TEMPORADAS IS 'Temporadas de series y podcasts. Cada temporada pertenece a un contenido';
COMMENT ON COLUMN TEMPORADAS.id_temporada IS 'Identificador unico de la temporada (PK)';
COMMENT ON COLUMN TEMPORADAS.id_contenido IS 'Contenido (serie o podcast) al que pertenece la temporada (FK a CONTENIDO)';
COMMENT ON COLUMN TEMPORADAS.numero_temporada IS 'Numero de la temporada (unico por contenido)';

-- =====================================================
-- TABLA 12: EPISODIOS
-- Episodios de cada temporada de series y podcasts.
-- Cada episodio pertenece a exactamente una temporada.
-- =====================================================
CREATE TABLE EPISODIOS (
    id_episodio         NUMBER          CONSTRAINT episodios_pk PRIMARY KEY,
    id_temporada        NUMBER          CONSTRAINT episodios_temp_nn NOT NULL,
    numero_episodio     NUMBER          CONSTRAINT episodios_num_nn NOT NULL,
    titulo_episodio     VARCHAR2(150),
    duracion_minutos    NUMBER          CONSTRAINT episodios_dur_nn NOT NULL,
    -- Restriccion: no puede haber dos episodios con el mismo numero en una temporada
    CONSTRAINT episodios_temp_num_uk UNIQUE (id_temporada, numero_episodio),
    CONSTRAINT episodios_num_ck CHECK (numero_episodio > 0),
    CONSTRAINT episodios_dur_ck CHECK (duracion_minutos > 0),
    -- Foreign Keys
    CONSTRAINT fk_ep_temporada FOREIGN KEY (id_temporada) REFERENCES TEMPORADAS(id_temporada)
);

COMMENT ON TABLE EPISODIOS IS 'Episodios individuales de cada temporada de series y podcasts';
COMMENT ON COLUMN EPISODIOS.id_episodio IS 'Identificador unico del episodio (PK)';
COMMENT ON COLUMN EPISODIOS.id_temporada IS 'Temporada a la que pertenece el episodio (FK a TEMPORADAS)';
COMMENT ON COLUMN EPISODIOS.numero_episodio IS 'Numero del episodio dentro de la temporada';
COMMENT ON COLUMN EPISODIOS.titulo_episodio IS 'Titulo del episodio';
COMMENT ON COLUMN EPISODIOS.duracion_minutos IS 'Duracion del episodio en minutos';

-- =====================================================
-- TABLA 13: CONTENIDO_RELACIONADO (Relacion Reflexiva M:N)
-- Relaciones entre contenidos: secuelas, precuelas,
-- remakes, spin-offs, versiones extendidas.
-- Relacion entre contenidos del mismo tipo o diferente.
-- =====================================================
CREATE TABLE CONTENIDO_RELACIONADO (
    id_contenido_origen     NUMBER          CONSTRAINT cr_origen_nn NOT NULL,
    id_contenido_destino    NUMBER          CONSTRAINT cr_destino_nn NOT NULL,
    tipo_relacion           VARCHAR2(50)    CONSTRAINT cr_tipo_nn NOT NULL,
    -- PK compuesta
    CONSTRAINT contenido_rel_pk PRIMARY KEY (id_contenido_origen, id_contenido_destino),
    -- No se puede relacionar un contenido consigo mismo
    CONSTRAINT cr_no_auto_ref CHECK (id_contenido_origen != id_contenido_destino),
    -- Foreign Keys
    CONSTRAINT fk_cr_origen FOREIGN KEY (id_contenido_origen) REFERENCES CONTENIDO(id_contenido),
    CONSTRAINT fk_cr_destino FOREIGN KEY (id_contenido_destino) REFERENCES CONTENIDO(id_contenido)
);

COMMENT ON TABLE CONTENIDO_RELACIONADO IS 'Relaciones entre contenidos: secuelas, precuelas, remakes, spin-offs, versiones extendidas';
COMMENT ON COLUMN CONTENIDO_RELACIONADO.id_contenido_origen IS 'Contenido de origen de la relacion (PK, FK a CONTENIDO)';
COMMENT ON COLUMN CONTENIDO_RELACIONADO.id_contenido_destino IS 'Contenido destino de la relacion (PK, FK a CONTENIDO)';
COMMENT ON COLUMN CONTENIDO_RELACIONADO.tipo_relacion IS 'Tipo de relacion: SECUELA, PRECUELA, REMAKE, SPIN-OFF, VERSION_EXTENDIDA, etc.';

-- =====================================================
-- TABLA 14: REPRODUCCIONES
-- Registro de cada reproduccion de contenido por perfil.
-- Incluye fecha/hora, dispositivo y progreso.
-- id_episodio es nullable (NULL para peliculas/docs/musica).
-- =====================================================
CREATE TABLE REPRODUCCIONES (
    id_reproduccion     NUMBER          CONSTRAINT reproducciones_pk PRIMARY KEY,
    id_perfil           NUMBER          CONSTRAINT repr_perfil_nn NOT NULL,
    id_contenido        NUMBER          CONSTRAINT repr_contenido_nn NOT NULL,
    id_episodio         NUMBER,         -- Nullable: NULL para peliculas, documentales, musica
    fecha_hora_inicio   TIMESTAMP       CONSTRAINT repr_inicio_nn NOT NULL,
    fecha_hora_fin      TIMESTAMP,      -- Nullable: NULL si no ha terminado
    dispositivo         VARCHAR2(20)    CONSTRAINT repr_disp_nn NOT NULL,
    porcentaje_avance   NUMBER(5,2)     DEFAULT 0,
    -- Restricciones de dominio
    CONSTRAINT repr_disp_ck CHECK (dispositivo IN ('CELULAR', 'TABLET', 'TV', 'COMPUTADOR')),
    CONSTRAINT repr_avance_ck CHECK (porcentaje_avance BETWEEN 0 AND 100),
    -- Foreign Keys
    CONSTRAINT fk_repr_perfil FOREIGN KEY (id_perfil) REFERENCES PERFILES(id_perfil),
    CONSTRAINT fk_repr_contenido FOREIGN KEY (id_contenido) REFERENCES CONTENIDO(id_contenido),
    CONSTRAINT fk_repr_episodio FOREIGN KEY (id_episodio) REFERENCES EPISODIOS(id_episodio)
);

COMMENT ON TABLE REPRODUCCIONES IS 'Registro de reproducciones de contenido por cada perfil. Tracking de consumo';
COMMENT ON COLUMN REPRODUCCIONES.id_reproduccion IS 'Identificador unico de la reproduccion (PK)';
COMMENT ON COLUMN REPRODUCCIONES.id_perfil IS 'Perfil que realizo la reproduccion (FK a PERFILES)';
COMMENT ON COLUMN REPRODUCCIONES.id_contenido IS 'Contenido reproducido (FK a CONTENIDO)';
COMMENT ON COLUMN REPRODUCCIONES.id_episodio IS 'Episodio especifico reproducido (FK a EPISODIOS, NULL para peliculas/docs/musica)';
COMMENT ON COLUMN REPRODUCCIONES.fecha_hora_inicio IS 'Fecha y hora de inicio de la reproduccion';
COMMENT ON COLUMN REPRODUCCIONES.fecha_hora_fin IS 'Fecha y hora de fin de la reproduccion (NULL si no termino)';
COMMENT ON COLUMN REPRODUCCIONES.dispositivo IS 'Dispositivo utilizado: CELULAR, TABLET, TV o COMPUTADOR';
COMMENT ON COLUMN REPRODUCCIONES.porcentaje_avance IS 'Porcentaje de avance de la reproduccion (0 a 100)';

-- =====================================================
-- TABLA 15: CALIFICACIONES
-- Calificaciones de contenido por perfiles.
-- Estrellas de 1 a 5 con resena opcional.
-- Un perfil solo puede calificar un contenido una vez.
-- =====================================================
CREATE TABLE CALIFICACIONES (
    id_calificacion     NUMBER          CONSTRAINT calificaciones_pk PRIMARY KEY,
    id_perfil           NUMBER          CONSTRAINT calif_perfil_nn NOT NULL,
    id_contenido        NUMBER          CONSTRAINT calif_contenido_nn NOT NULL,
    estrellas           NUMBER(1)       CONSTRAINT calif_estrellas_nn NOT NULL,
    resena              VARCHAR2(1000),
    fecha_calificacion  DATE            DEFAULT SYSDATE,
    -- Restricciones de dominio
    CONSTRAINT calif_estrellas_ck CHECK (estrellas BETWEEN 1 AND 5),
    -- Un perfil solo puede calificar un contenido una vez
    CONSTRAINT calif_perfil_cont_uk UNIQUE (id_perfil, id_contenido),
    -- Foreign Keys
    CONSTRAINT fk_calif_perfil FOREIGN KEY (id_perfil) REFERENCES PERFILES(id_perfil),
    CONSTRAINT fk_calif_contenido FOREIGN KEY (id_contenido) REFERENCES CONTENIDO(id_contenido)
);

COMMENT ON TABLE CALIFICACIONES IS 'Calificaciones de contenido por perfiles con estrellas (1-5) y resena opcional';
COMMENT ON COLUMN CALIFICACIONES.id_calificacion IS 'Identificador unico de la calificacion (PK)';
COMMENT ON COLUMN CALIFICACIONES.id_perfil IS 'Perfil que realizo la calificacion (FK a PERFILES)';
COMMENT ON COLUMN CALIFICACIONES.id_contenido IS 'Contenido calificado (FK a CONTENIDO)';
COMMENT ON COLUMN CALIFICACIONES.estrellas IS 'Calificacion en estrellas del 1 al 5';
COMMENT ON COLUMN CALIFICACIONES.resena IS 'Resena escrita opcional del contenido';
COMMENT ON COLUMN CALIFICACIONES.fecha_calificacion IS 'Fecha en que se realizo la calificacion';

-- =====================================================
-- TABLA 16: FAVORITOS
-- Lista personal de contenido favorito por perfil.
-- Un perfil puede agregar un contenido a favoritos
-- solo una vez.
-- =====================================================
CREATE TABLE FAVORITOS (
    id_favorito     NUMBER  CONSTRAINT favoritos_pk PRIMARY KEY,
    id_perfil       NUMBER  CONSTRAINT fav_perfil_nn NOT NULL,
    id_contenido    NUMBER  CONSTRAINT fav_contenido_nn NOT NULL,
    fecha_agregado  DATE    DEFAULT SYSDATE,
    -- Un perfil solo puede tener un contenido en favoritos una vez
    CONSTRAINT fav_perfil_cont_uk UNIQUE (id_perfil, id_contenido),
    -- Foreign Keys
    CONSTRAINT fk_fav_perfil FOREIGN KEY (id_perfil) REFERENCES PERFILES(id_perfil),
    CONSTRAINT fk_fav_contenido FOREIGN KEY (id_contenido) REFERENCES CONTENIDO(id_contenido)
);

COMMENT ON TABLE FAVORITOS IS 'Lista personal de contenido favorito de cada perfil';
COMMENT ON COLUMN FAVORITOS.id_favorito IS 'Identificador unico del favorito (PK)';
COMMENT ON COLUMN FAVORITOS.id_perfil IS 'Perfil que agrego el favorito (FK a PERFILES)';
COMMENT ON COLUMN FAVORITOS.id_contenido IS 'Contenido marcado como favorito (FK a CONTENIDO)';
COMMENT ON COLUMN FAVORITOS.fecha_agregado IS 'Fecha en que se agrego a favoritos';

-- =====================================================
-- TABLA 17: REPORTES
-- Reportes de contenido inapropiado realizados por
-- usuarios. Un moderador (empleado de Soporte) revisa
-- y resuelve cada reporte.
-- =====================================================
CREATE TABLE REPORTES (
    id_reporte              NUMBER          CONSTRAINT reportes_pk PRIMARY KEY,
    id_perfil               NUMBER          CONSTRAINT rep_perfil_nn NOT NULL,
    id_contenido            NUMBER          CONSTRAINT rep_contenido_nn NOT NULL,
    id_empleado_moderador   NUMBER,         -- Nullable hasta que se asigne un moderador
    descripcion_reporte     VARCHAR2(500)   CONSTRAINT rep_desc_nn NOT NULL,
    estado_reporte          VARCHAR2(20)    DEFAULT 'PENDIENTE',
    resolucion_descripcion  VARCHAR2(500),  -- Nullable hasta que se resuelva
    fecha_reporte           DATE            DEFAULT SYSDATE,
    fecha_resolucion        DATE,           -- Nullable hasta que se resuelva
    -- Restricciones de dominio
    CONSTRAINT rep_estado_ck CHECK (estado_reporte IN ('PENDIENTE', 'EN_REVISION', 'RESUELTO', 'RECHAZADO')),
    -- Foreign Keys
    CONSTRAINT fk_rep_perfil FOREIGN KEY (id_perfil) REFERENCES PERFILES(id_perfil),
    CONSTRAINT fk_rep_contenido FOREIGN KEY (id_contenido) REFERENCES CONTENIDO(id_contenido),
    CONSTRAINT fk_rep_moderador FOREIGN KEY (id_empleado_moderador) REFERENCES EMPLEADOS(id_empleado)
);

COMMENT ON TABLE REPORTES IS 'Reportes de contenido inapropiado enviados por usuarios y revisados por moderadores';
COMMENT ON COLUMN REPORTES.id_reporte IS 'Identificador unico del reporte (PK)';
COMMENT ON COLUMN REPORTES.id_perfil IS 'Perfil que reporto el contenido (FK a PERFILES)';
COMMENT ON COLUMN REPORTES.id_contenido IS 'Contenido reportado como inapropiado (FK a CONTENIDO)';
COMMENT ON COLUMN REPORTES.id_empleado_moderador IS 'Moderador asignado para revisar el reporte (FK a EMPLEADOS, nullable)';
COMMENT ON COLUMN REPORTES.descripcion_reporte IS 'Descripcion detallada del motivo del reporte';
COMMENT ON COLUMN REPORTES.estado_reporte IS 'Estado del reporte: PENDIENTE, EN_REVISION, RESUELTO, RECHAZADO';
COMMENT ON COLUMN REPORTES.resolucion_descripcion IS 'Descripcion de la resolucion dada por el moderador';
COMMENT ON COLUMN REPORTES.fecha_reporte IS 'Fecha en que se creo el reporte';
COMMENT ON COLUMN REPORTES.fecha_resolucion IS 'Fecha en que se resolvio el reporte';

-- =====================================================
-- TABLA 18: PAGOS
-- Registro de pagos mensuales de suscripcion.
-- Incluye metodo de pago, estado y fecha de vencimiento
-- para control de mora (30 dias).
-- =====================================================
CREATE TABLE PAGOS (
    id_pago             NUMBER          CONSTRAINT pagos_pk PRIMARY KEY,
    id_usuario          NUMBER          CONSTRAINT pagos_usuario_nn NOT NULL,
    fecha_pago          DATE            CONSTRAINT pagos_fecha_nn NOT NULL,
    fecha_vencimiento   DATE            CONSTRAINT pagos_venc_nn NOT NULL,
    monto               NUMBER(10,2)    CONSTRAINT pagos_monto_nn NOT NULL,
    metodo_pago         VARCHAR2(30)    CONSTRAINT pagos_metodo_nn NOT NULL,
    estado_pago         VARCHAR2(20)    CONSTRAINT pagos_estado_nn NOT NULL,
    -- Restricciones de dominio
    CONSTRAINT pagos_monto_ck CHECK (monto > 0),
    CONSTRAINT pagos_metodo_ck CHECK (metodo_pago IN ('TARJETA_CREDITO', 'TARJETA_DEBITO', 'PSE', 'NEQUI', 'DAVIPLATA')),
    CONSTRAINT pagos_estado_ck CHECK (estado_pago IN ('EXITOSO', 'FALLIDO', 'PENDIENTE', 'REEMBOLSADO')),
    -- Foreign Keys
    CONSTRAINT fk_pago_usuario FOREIGN KEY (id_usuario) REFERENCES USUARIOS(id_usuario)
);

COMMENT ON TABLE PAGOS IS 'Registro de pagos mensuales de suscripcion de los usuarios';
COMMENT ON COLUMN PAGOS.id_pago IS 'Identificador unico del pago (PK)';
COMMENT ON COLUMN PAGOS.id_usuario IS 'Usuario que realizo el pago (FK a USUARIOS)';
COMMENT ON COLUMN PAGOS.fecha_pago IS 'Fecha en que se proceso el pago';
COMMENT ON COLUMN PAGOS.fecha_vencimiento IS 'Fecha limite de pago (control de mora a 30 dias)';
COMMENT ON COLUMN PAGOS.monto IS 'Monto pagado en pesos colombianos';
COMMENT ON COLUMN PAGOS.metodo_pago IS 'Metodo de pago: TARJETA_CREDITO, TARJETA_DEBITO, PSE, NEQUI, DAVIPLATA';
COMMENT ON COLUMN PAGOS.estado_pago IS 'Estado del pago: EXITOSO, FALLIDO, PENDIENTE, REEMBOLSADO';

-- =====================================================
-- TABLA 19: HISTORIAL_PLANES
-- Registra los cambios de plan de suscripcion.
-- Necesario para SP_CAMBIAR_PLAN y auditoria.
-- =====================================================
CREATE TABLE HISTORIAL_PLANES (
    id_historial        NUMBER          CONSTRAINT historial_pk PRIMARY KEY,
    id_usuario          NUMBER          CONSTRAINT hist_usuario_nn NOT NULL,
    id_plan_anterior    NUMBER          CONSTRAINT hist_plan_ant_nn NOT NULL,
    id_plan_nuevo       NUMBER          CONSTRAINT hist_plan_nuevo_nn NOT NULL,
    fecha_cambio        DATE            DEFAULT SYSDATE,
    motivo              VARCHAR2(200),
    -- Foreign Keys
    CONSTRAINT fk_hist_usuario FOREIGN KEY (id_usuario) REFERENCES USUARIOS(id_usuario),
    CONSTRAINT fk_hist_plan_ant FOREIGN KEY (id_plan_anterior) REFERENCES PLANES(id_plan),
    CONSTRAINT fk_hist_plan_nuevo FOREIGN KEY (id_plan_nuevo) REFERENCES PLANES(id_plan)
);

COMMENT ON TABLE HISTORIAL_PLANES IS 'Historial de cambios de plan de suscripcion de los usuarios';
COMMENT ON COLUMN HISTORIAL_PLANES.id_historial IS 'Identificador unico del registro de historial (PK)';
COMMENT ON COLUMN HISTORIAL_PLANES.id_usuario IS 'Usuario que cambio de plan (FK a USUARIOS)';
COMMENT ON COLUMN HISTORIAL_PLANES.id_plan_anterior IS 'Plan anterior del usuario (FK a PLANES)';
COMMENT ON COLUMN HISTORIAL_PLANES.id_plan_nuevo IS 'Nuevo plan del usuario (FK a PLANES)';
COMMENT ON COLUMN HISTORIAL_PLANES.fecha_cambio IS 'Fecha en que se realizo el cambio de plan';
COMMENT ON COLUMN HISTORIAL_PLANES.motivo IS 'Motivo del cambio de plan (opcional)';

-- =====================================================
-- TABLA 20: DESCUENTOS_REFERIDOS
-- Gestion de descuentos otorgados por referir nuevos
-- usuarios. Tanto referidor como referido reciben
-- un descuento en su proximo pago.
-- =====================================================
CREATE TABLE DESCUENTOS_REFERIDOS (
    id_descuento            NUMBER          CONSTRAINT descuentos_pk PRIMARY KEY,
    id_usuario_referidor    NUMBER          CONSTRAINT desc_referidor_nn NOT NULL,
    id_usuario_referido     NUMBER          CONSTRAINT desc_referido_nn NOT NULL,
    porcentaje_descuento    NUMBER(5,2)     DEFAULT 10,
    estado                  VARCHAR2(20)    DEFAULT 'PENDIENTE',
    fecha_aplicacion        DATE,
    -- Restricciones de dominio
    CONSTRAINT desc_porcentaje_ck CHECK (porcentaje_descuento BETWEEN 0 AND 100),
    CONSTRAINT desc_estado_ck CHECK (estado IN ('PENDIENTE', 'APLICADO', 'EXPIRADO')),
    CONSTRAINT desc_no_auto_ref CHECK (id_usuario_referidor != id_usuario_referido),
    -- Foreign Keys
    CONSTRAINT fk_desc_referidor FOREIGN KEY (id_usuario_referidor) REFERENCES USUARIOS(id_usuario),
    CONSTRAINT fk_desc_referido FOREIGN KEY (id_usuario_referido) REFERENCES USUARIOS(id_usuario)
);

COMMENT ON TABLE DESCUENTOS_REFERIDOS IS 'Gestion de descuentos por programa de referidos de QuindioFlix';
COMMENT ON COLUMN DESCUENTOS_REFERIDOS.id_descuento IS 'Identificador unico del descuento (PK)';
COMMENT ON COLUMN DESCUENTOS_REFERIDOS.id_usuario_referidor IS 'Usuario que refirio al nuevo usuario (FK a USUARIOS)';
COMMENT ON COLUMN DESCUENTOS_REFERIDOS.id_usuario_referido IS 'Usuario que fue referido (FK a USUARIOS)';
COMMENT ON COLUMN DESCUENTOS_REFERIDOS.porcentaje_descuento IS 'Porcentaje de descuento aplicado (default 10%)';
COMMENT ON COLUMN DESCUENTOS_REFERIDOS.estado IS 'Estado del descuento: PENDIENTE, APLICADO, EXPIRADO';
COMMENT ON COLUMN DESCUENTOS_REFERIDOS.fecha_aplicacion IS 'Fecha en que se aplico el descuento al pago';

-- =====================================================
-- SECCION 3: VERIFICACION
-- Consulta para verificar que todas las tablas y
-- secuencias se crearon correctamente.
-- =====================================================

-- Verificar tablas creadas
SELECT table_name, num_rows 
FROM user_tables 
WHERE table_name IN (
    'PLANES', 'CIUDADES', 'USUARIOS', 'PERFILES', 'CATEGORIAS', 'GENEROS',
    'DEPARTAMENTOS', 'EMPLEADOS', 'CONTENIDO', 'CONTENIDO_GENERO',
    'TEMPORADAS', 'EPISODIOS', 'CONTENIDO_RELACIONADO', 'REPRODUCCIONES',
    'CALIFICACIONES', 'FAVORITOS', 'REPORTES', 'PAGOS',
    'HISTORIAL_PLANES', 'DESCUENTOS_REFERIDOS'
)
ORDER BY table_name;

-- Verificar secuencias creadas
SELECT sequence_name, last_number 
FROM user_sequences 
WHERE sequence_name LIKE 'SEQ_%'
ORDER BY sequence_name;

-- Verificar restricciones creadas
SELECT table_name, constraint_name, constraint_type 
FROM user_constraints 
WHERE table_name IN (
    'PLANES', 'CIUDADES', 'USUARIOS', 'PERFILES', 'CATEGORIAS', 'GENEROS',
    'DEPARTAMENTOS', 'EMPLEADOS', 'CONTENIDO', 'CONTENIDO_GENERO',
    'TEMPORADAS', 'EPISODIOS', 'CONTENIDO_RELACIONADO', 'REPRODUCCIONES',
    'CALIFICACIONES', 'FAVORITOS', 'REPORTES', 'PAGOS',
    'HISTORIAL_PLANES', 'DESCUENTOS_REFERIDOS'
)
ORDER BY table_name, constraint_type;

PROMPT '=====================================================';
PROMPT 'QuindioFlix - Creacion de tablas completada';
PROMPT '20 tablas, 18 secuencias, todas las restricciones';
PROMPT '=====================================================';
