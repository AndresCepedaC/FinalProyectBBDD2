# QUINDIOFLIX - DOCUMENTO DE MODELO DE NEGOCIO
## Proyecto Final - Bases de Datos II
### Universidad del QuindÃ­o

---

## 1. INTRODUCCIÃ“N Y CONTEXTO
QuindioFlix es una plataforma de streaming de contenido multimedia (pelÃ­culas, series, documentales, mÃºsica y podcasts) diseÃ±ada para operar en el territorio colombiano. En un entorno tecnolÃ³gico altamente competitivo y dinÃ¡mico, la plataforma requiere una base de datos robusta, escalable y transaccional que soporte tanto la operaciÃ³n diaria de millones de reproducciones concurrentes como la gestiÃ³n administrativa de planes, facturaciÃ³n, soporte tÃ©cnico, moderaciÃ³n de contenidos y auditorÃ­a interna.

Este documento detalla el modelo de negocio de QuindioFlix, identificando sus actores clave, procesos operativos, reglas de negocio fundamentales y restricciones de dominio implementadas a nivel de base de datos para garantizar la integridad, consistencia y seguridad del sistema.

---

## 2. ACTORES DEL NEGOCIO
Los actores representan los roles internos y externos que interactÃºan con el ecosistema de QuindioFlix. En la base de datos, estas interacciones estÃ¡n modeladas en tablas especÃ­ficas y controladas a travÃ©s de permisos y roles de seguridad:

### A. Suscriptor / Usuario Principal (`USUARIOS`)
Es la persona que adquiere el contrato de suscripciÃ³n de QuindioFlix en Colombia.
*   **Responsabilidades:** Registrarse, seleccionar y pagar su plan de suscripciÃ³n mensual, gestionar la informaciÃ³n de facturaciÃ³n, crear y configurar perfiles, referir nuevos usuarios y administrar el estado de su cuenta.
*   **RepresentaciÃ³n en BD:** Tabla `USUARIOS`. Se asocia con `PLANES`, `CIUDADES` y posee una relaciÃ³n reflexiva para la gestiÃ³n de referidos.

### B. Perfil (`PERFILES`)
Es cada una de las identidades de uso individual creadas bajo la cuenta del Suscriptor Principal.
*   **Responsabilidades:** Consumir contenido (reproducciones), calificar y reseÃ±ar tÃ­tulos, guardar listas de favoritos y reportar contenido inapropiado.
*   **Tipos de Perfiles:** 
    *   *ADULTO:* Acceso a todo el catÃ¡logo disponible en la plataforma sin restricciones.
    *   *INFANTIL:* Acceso restringido Ãºnicamente a contenidos con clasificaciÃ³n apta para menores de edad.
*   **RepresentaciÃ³n en BD:** Tabla `PERFILES` (relaciÃ³n 1:N con `USUARIOS`).

### C. Empleado de Contenido / Publicador (`EMPLEADOS` de Departamento 'Contenido')
Es el personal interno de QuindioFlix encargado de curar y gestionar el catÃ¡logo multimedia disponible.
*   **Responsabilidades:** Registrar pelÃ­culas, series, temporadas, episodios, documentales, mÃºsica y podcasts, clasificar los tÃ­tulos por gÃ©neros y categorÃ­as, establecer relaciones entre contenidos (secuelas, spin-offs) y actualizar la disponibilidad de los tÃ­tulos.
*   **RepresentaciÃ³n en BD:** Tabla `EMPLEADOS` con `id_departamento` correspondiente a "Contenido". Su ID se registra en la tabla `CONTENIDO` como `id_empleado_publicador` para fines de auditorÃ­a.

### D. Empleado de Soporte / Moderador (`EMPLEADOS` de Departamento 'Soporte')
Es el personal de atenciÃ³n al cliente y aseguramiento de polÃ­ticas de la plataforma.
*   **Responsabilidades:** Atender, investigar y resolver los reportes de contenido inapropiado enviados por los perfiles de los usuarios.
*   **RepresentaciÃ³n en BD:** Tabla `EMPLEADOS` con `id_departamento` correspondiente a "Soporte". Se asocia a la tabla `REPORTES` a travÃ©s del campo `id_empleado_moderador`.

### E. Administrador del Sistema (`USR_ADMIN` / Personal de TecnologÃ­a)
Usuario de base de datos con privilegios completos encargado del mantenimiento preventivo, optimizaciones e infraestructura.
*   **Responsabilidades:** Administrar la base de datos, configurar perfiles de seguridad, gestionar la creaciÃ³n de tablas, Ã­ndices y roles, y realizar auditorÃ­as de transacciones.
*   **RepresentaciÃ³n en BD:** Usuario corporativo Oracle `USR_ADMIN` con asignaciÃ³n del rol `ROL_ADMIN`.

---

## 3. PROCESOS DE NEGOCIO
Los procesos de negocio describen las secuencias de actividades necesarias para cumplir los objetivos operativos de QuindioFlix:

### A. Registro, SuscripciÃ³n y Pago Inicial
Cuando un cliente desea unirse a QuindioFlix, ingresa sus datos personales, selecciona su ciudad de residencia y escoge uno de los tres planes de suscripciÃ³n (BÃ¡sico, EstÃ¡ndar, Premium). 
*   **Flujo TÃ©cnico:** El sistema inicia una transacciÃ³n de base de datos. Se inserta el registro en `USUARIOS`, se genera automÃ¡ticamente un perfil primario de tipo `ADULTO` en `PERFILES`, y se procesa el cobro en `PAGOS`. Si la pasarela de pagos confirma el cobro como `EXITOSO`, se consolida la transacciÃ³n (`COMMIT`). En caso de fallo en la pasarela o de datos duplicados (ej. correo ya registrado), se deshacen todos los cambios (`ROLLBACK`) para evitar cuentas huÃ©rfanas sin pago o datos corruptos.

### B. Control y GestiÃ³n de Perfiles
Un usuario puede crear mÃºltiples perfiles para los miembros de su hogar, permitiendo que cada uno tenga sus propios favoritos, historial y recomendaciones personalizadas.
*   **Flujo TÃ©cnico:** Al intentar crear un nuevo perfil, un disparador (`TRG_LIMITE_PERFILES`) intercepta la inserciÃ³n y valida la cantidad de perfiles actuales contra el lÃ­mite permitido por su plan (`PLANES.max_perfiles`). Si supera el lÃ­mite, se cancela la inserciÃ³n mediante una excepciÃ³n personalizada. Al cambiar de plan (`SP_CAMBIAR_PLAN`), el sistema valida que los perfiles ya creados no excedan el lÃ­mite del nuevo plan antes de proceder con el cambio y de registrar el movimiento en `HISTORIAL_PLANES`.

### C. Consumo y Seguimiento de Reproducciones (Tracking de Avance)
Cuando un perfil inicia un video o pista de audio, la aplicaciÃ³n registra el evento para permitir la funcionalidad "Continuar viendo" y calcular recomendaciones personalizadas.
*   **Flujo TÃ©cnico:** Al iniciar, se inserta una fila en `REPRODUCCIONES` con `fecha_hora_inicio` y un trigger (`trg_validar_cuenta_reproduccion`) verifica que el usuario de ese perfil tenga su cuenta en estado `ACTIVO`. Mientras el usuario reproduce, el porcentaje de avance se actualiza en la base de datos. Si el avance alcanza el 90% o mÃ¡s, un proceso en lote calcula de forma asÃ­ncrona la popularidad del contenido (`CONTENIDO.popularidad`), sumando las reproducciones completadas exitosamente.

### D. Programa de FidelizaciÃ³n por Referidos
Para fomentar el crecimiento orgÃ¡nico, QuindioFlix otorga un 10% de descuento en la siguiente mensualidad tanto al usuario que refiere (Referidor) como al nuevo usuario registrado (Referido).
*   **Flujo TÃ©cnico:** Al registrarse el nuevo usuario con el cÃ³digo de su referidor, se inserta una fila en `DESCUENTOS_REFERIDOS` en estado `PENDIENTE`. Cuando el sistema corre la facturaciÃ³n mensual masiva, detecta si hay descuentos pendientes aplicables a los involucrados, calcula el monto final mediante la funciÃ³n `FN_CALCULAR_MONTO`, aplica el descuento y actualiza el estado del registro a `APLICADO`.

### E. ModeraciÃ³n y Reporte de Contenidos
Si un usuario considera que una escena o parte de un contenido infringe las polÃ­ticas (por ejemplo, clasificaciÃ³n de edad incorrecta, lenguaje inapropiado), puede reportarlo.
*   **Flujo TÃ©cnico:** El perfil envÃ­a un reporte que se almacena en `REPORTES` con estado `PENDIENTE`. Un empleado del departamento de Soporte toma el caso (el estado pasa a `EN_REVISION` y se asigna su `id_empleado_moderador`). Tras la investigaciÃ³n, el moderador determina si el reporte es `RESUELTO` (por ejemplo, modificando la sinopsis o la clasificaciÃ³n de edad de la tabla `CONTENIDO` a travÃ©s de un procedimiento) o `RECHAZADO`, registrando la justificaciÃ³n del cierre.

---

## 4. REGLAS DE NEGOCIO (MÃNIMO 10)
Las reglas de negocio son directrices obligatorias que rigen la operaciÃ³n de la empresa y que han sido codificadas en la estructura de la base de datos mediante restricciones DDL (`CHECK`, `UNIQUE`, `FOREIGN KEY`), disparadores (`TRIGGERS`) o procedimientos almacenados (`STORED PROCEDURES`):

1.  **Regla de Acceso por Estado de Cuenta (Frenado de Mora):** Un perfil solo puede reproducir contenido si el estado de la cuenta del suscriptor estÃ¡ marcado como `ACTIVO`. Si la cuenta estÃ¡ `INACTIVO` o `SUSPENDIDO`, el sistema bloquea inmediatamente la inserciÃ³n en la tabla `REPRODUCCIONES` (Implementado vÃ­a trigger `trg_validar_cuenta_reproduccion`).
2.  **Regla de LÃ­mite de Perfiles por Plan:** El nÃºmero total de perfiles activos en una cuenta de usuario no puede exceder la capacidad establecida por el plan contratado: BÃ¡sico (mÃ¡ximo 2 perfiles), EstÃ¡ndar (mÃ¡ximo 3 perfiles) y Premium (mÃ¡ximo 5 perfiles) (Implementado vÃ­a trigger `TRG_LIMITE_PERFILES`).
3.  **Regla de Requisito MÃ­nimo de VisualizaciÃ³n para Calificar:** Un perfil solo puede calificar y dejar una reseÃ±a escrita sobre un contenido si ha reproducido al menos el 50% de su duraciÃ³n (Implementado vÃ­a trigger `trg_validar_calificacion`, con `JOIN` entre `CALIFICACIONES`, `REPRODUCCIONES` y `CONTENIDO`).
4.  **Regla de RestricciÃ³n de DegradaciÃ³n de Planes (Downgrade):** Un suscriptor no puede cambiarse a un plan inferior si el nÃºmero de perfiles que tiene actualmente creados supera el lÃ­mite mÃ¡ximo permitido por el nuevo plan de destino (Implementado vÃ­a validaciÃ³n lÃ³gica en el procedimiento `SP_CAMBIAR_PLAN`).
5.  **Regla de Control de SuscripciÃ³n Vencida (Mora 30 DÃ­as):** Un usuario entra en estado moroso si han transcurrido mÃ¡s de 30 dÃ­as calendario desde su Ãºltimo pago mensual exitoso registrado. Las cuentas en esta condiciÃ³n se extraen mediante consultas automatizadas para su suspensiÃ³n (Implementado mediante cursor `c_usuarios_morosos` y proceso batch nocturno).
6.  **Regla de Tarifas Positivas:** El precio mensual de cualquier plan de suscripciÃ³n registrado en la plataforma debe ser estrictamente mayor que cero pesos colombianos (Implementado vÃ­a restricciÃ³n DDL `planes_precio_ck` en la tabla `PLANES`).
7.  **Regla de Rango de Avance de ReproducciÃ³n:** El porcentaje de avance en cualquier reproducciÃ³n debe ser un valor decimal comprendido obligatoriamente entre 0.00% y 100.00% (Implementado vÃ­a restricciÃ³n DDL `repr_avance_ck` en la tabla `REPRODUCCIONES`).
8.  **Regla de Unicidad de Calificaciones:** Un perfil especÃ­fico de usuario solo puede calificar un determinado contenido del catÃ¡logo una Ãºnica vez en el sistema, impidiendo la manipulaciÃ³n fraudulenta de la popularidad de los tÃ­tulos (Implementado vÃ­a clave Ãºnica compuesta `calif_perfil_cont_uk` en la tabla `CALIFICACIONES`).
9.  **Regla de PrevenciÃ³n de Autorreferidos:** Un suscriptor no puede registrarse como referido de sÃ­ mismo, ni otorgar descuentos de programa de referidos a su propia cuenta (Implementado vÃ­a restricciÃ³n DDL `desc_no_auto_ref` en la tabla `DESCUENTOS_REFERIDOS`).
10. **Regla de PrevenciÃ³n de Autoenlaces de CatÃ¡logo:** Un contenido multimedia no puede relacionarse consigo mismo como precuela, secuela, remake o spin-off (Implementado vÃ­a restricciÃ³n DDL `cr_no_auto_ref` en la tabla `CONTENIDO_RELACIONADO`).
11. **Regla de ActivaciÃ³n AutomÃ¡tica por Pago:** Cuando se registra un pago mensual con estado `EXITOSO` para una cuenta que estaba suspendida o inactiva, su estado debe actualizarse automÃ¡ticamente a `ACTIVO` y la fecha de Ãºltimo pago debe establecerse al dÃ­a actual (Implementado vÃ­a trigger `trg_actualizar_estado_cuenta`).
12. **Regla de Consistencia en Temporadas de Contenido:** Un contenido del catÃ¡logo (Serie o Podcast) no puede tener dos temporadas registradas con el mismo nÃºmero de orden (Implementado vÃ­a restricciÃ³n de unicidad compuesta `temporadas_cont_num_uk` en la tabla `TEMPORADAS`).
13. **Regla de Consistencia en Episodios:** Una temporada especÃ­fica de una serie o podcast no puede registrar dos episodios con el mismo nÃºmero de orden correlativo (Implementado vÃ­a restricciÃ³n de unicidad compuesta `episodios_temp_num_uk` en la tabla `EPISODIOS`).
14. **Regla de Calidad de Video Homologada:** La calidad mÃ¡xima admitida en los planes de suscripciÃ³n se limita estrictamente a los formatos comerciales estÃ¡ndar: 'SD' (definiciÃ³n estÃ¡ndar), 'HD' (alta definiciÃ³n) y '4K' (ultra alta definiciÃ³n) (Implementado vÃ­a restricciÃ³n CHECK `planes_calidad_ck` en la tabla `PLANES`).
15. **Regla de ClasificaciÃ³n de Edad del CatÃ¡logo:** Todo contenido agregado al catÃ¡logo debe pertenecer obligatoriamente a una de las cinco clasificaciones de edad colombianas vÃ¡lidas: 'TP' (Todo PÃºblico), '+7', '+13', '+16', '+18' (Implementado vÃ­a restricciÃ³n CHECK `contenido_clasif_ck` en la tabla `CONTENIDO`).

---

## 5. RESTRICCIONES DEL DOMINIO
Las restricciones del dominio especifican los lÃ­mites, tipos de datos y formatos permitidos para las columnas individuales de las tablas:

*   **Valores No Nulos (`NOT NULL`):** Atributos fundamentales de negocio que no pueden quedar vacÃ­os bajo ninguna circunstancia, tales como el `email` de un usuario, el `nombre_plan` de un plan, la `duracion_minutos` de un episodio, o las `estrellas` de una calificaciÃ³n.
*   **Identificadores Ãšnicos (`UNIQUE`):** Campos lÃ³gicos que deben ser Ãºnicos globalmente, como el correo electrÃ³nico del suscriptor (`usuarios_email_uk`) para impedir registros duplicados, el correo de empleados (`empleados_email_uk`), o el nombre de las ciudades (`ciudades_nombre_uk`).
*   **Claves Primarias (`PRIMARY KEY`):** Identificadores numÃ©ricos generados secuencialmente que garantizan la identidad Ãºnica de cada registro en las 20 tablas.
*   **Claves ForÃ¡neas (`FOREIGN KEY`):** Restricciones de integridad referencial que impiden el registro de datos huÃ©rfanos. Por ejemplo, no se puede registrar una reproducciÃ³n para un perfil inexistente o un pago para un usuario eliminado.
*   **Tipos y Longitudes de Datos:**
    *   Nombres y tÃ­tulos: Limitados en base a `VARCHAR2` entre `50` y `150` caracteres segÃºn el volumen.
    *   Sinopsis y reseÃ±as: Definidas con `VARCHAR2(2000)` y `VARCHAR2(1000)` respectivamente para almacenar textos enriquecidos medianamente largos sin penalizar el almacenamiento.
    *   Campos monetarios: Definidos con precisiÃ³n decimal `NUMBER(10,2)` para asegurar que no ocurran errores de redondeo de centavos en cobros y reportes financieros.
    *   Fechas y Horas: Representadas con `DATE` (para fechas simples de nacimiento o registro) y `TIMESTAMP` (para precisiones de milisegundos en el registro de inicio y fin de visualizaciones en la tabla `REPRODUCCIONES`).

