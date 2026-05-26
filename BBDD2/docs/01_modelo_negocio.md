# QUINDIOFLIX - DOCUMENTO DE MODELO DE NEGOCIO
## Proyecto Final - Bases de Datos II
### Universidad del Quindío

---

## 1. INTRODUCCIÓN Y CONTEXTO
QuindioFlix es una plataforma de streaming de contenido multimedia (películas, series, documentales, música y podcasts) diseñada para operar en el territorio colombiano. En un entorno tecnológico altamente competitivo y dinámico, la plataforma requiere una base de datos robusta, escalable y transaccional que soporte tanto la operación diaria de millones de reproducciones concurrentes como la gestión administrativa de planes, facturación, soporte técnico, moderación de contenidos y auditoría interna.

Este documento detalla el modelo de negocio de QuindioFlix, identificando sus actores clave, procesos operativos, reglas de negocio fundamentales y restricciones de dominio implementadas a nivel de base de datos para garantizar la integridad, consistencia y seguridad del sistema.

---

## 2. ACTORES DEL NEGOCIO
Los actores representan los roles internos y externos que interactúan con el ecosistema de QuindioFlix. En la base de datos, estas interacciones están modeladas en tablas específicas y controladas a través de permisos y roles de seguridad:

### A. Suscriptor / Usuario Principal (`USUARIOS`)
Es la persona que adquiere el contrato de suscripción de QuindioFlix en Colombia.
*   **Responsabilidades:** Registrarse, seleccionar y pagar su plan de suscripción mensual, gestionar la información de facturación, crear y configurar perfiles, referir nuevos usuarios y administrar el estado de su cuenta.
*   **Representación en BD:** Tabla `USUARIOS`. Se asocia con `PLANES`, `CIUDADES` y posee una relación reflexiva para la gestión de referidos.

### B. Perfil (`PERFILES`)
Es cada una de las identidades de uso individual creadas bajo la cuenta del Suscriptor Principal.
*   **Responsabilidades:** Consumir contenido (reproducciones), calificar y reseñar títulos, guardar listas de favoritos y reportar contenido inapropiado.
*   **Tipos de Perfiles:** 
    *   *ADULTO:* Acceso a todo el catálogo disponible en la plataforma sin restricciones.
    *   *INFANTIL:* Acceso restringido únicamente a contenidos con clasificación apta para menores de edad.
*   **Representación en BD:** Tabla `PERFILES` (relación 1:N con `USUARIOS`).

### C. Empleado de Contenido / Publicador (`EMPLEADOS` de Departamento 'Contenido')
Es el personal interno de QuindioFlix encargado de curar y gestionar el catálogo multimedia disponible.
*   **Responsabilidades:** Registrar películas, series, temporadas, episodios, documentales, música y podcasts, clasificar los títulos por géneros y categorías, establecer relaciones entre contenidos (secuelas, spin-offs) y actualizar la disponibilidad de los títulos.
*   **Representación en BD:** Tabla `EMPLEADOS` con `id_departamento` correspondiente a "Contenido". Su ID se registra en la tabla `CONTENIDO` como `id_empleado_publicador` para fines de auditoría.

### D. Empleado de Soporte / Moderador (`EMPLEADOS` de Departamento 'Soporte')
Es el personal de atención al cliente y aseguramiento de políticas de la plataforma.
*   **Responsabilidades:** Atender, investigar y resolver los reportes de contenido inapropiado enviados por los perfiles de los usuarios.
*   **Representación en BD:** Tabla `EMPLEADOS` con `id_departamento` correspondiente a "Soporte". Se asocia a la tabla `REPORTES` a través del campo `id_empleado_moderador`.

### E. Administrador del Sistema (`USR_ADMIN` / Personal de Tecnología)
Usuario de base de datos con privilegios completos encargado del mantenimiento preventivo, optimizaciones e infraestructura.
*   **Responsabilidades:** Administrar la base de datos, configurar perfiles de seguridad, gestionar la creación de tablas, índices y roles, y realizar auditorías de transacciones.
*   **Representación en BD:** Usuario corporativo Oracle `USR_ADMIN` con asignación del rol `ROL_ADMIN`.

---

## 3. PROCESOS DE NEGOCIO
Los procesos de negocio describen las secuencias de actividades necesarias para cumplir los objetivos operativos de QuindioFlix:

### A. Registro, Suscripción y Pago Inicial
Cuando un cliente desea unirse a QuindioFlix, ingresa sus datos personales, selecciona su ciudad de residencia y escoge uno de los tres planes de suscripción (Básico, Estándar, Premium). 
*   **Flujo Técnico:** El sistema inicia una transacción de base de datos. Se inserta el registro en `USUARIOS`, se genera automáticamente un perfil primario de tipo `ADULTO` en `PERFILES`, y se procesa el cobro en `PAGOS`. Si la pasarela de pagos confirma el cobro como `EXITOSO`, se consolida la transacción (`COMMIT`). En caso de fallo en la pasarela o de datos duplicados (ej. correo ya registrado), se deshacen todos los cambios (`ROLLBACK`) para evitar cuentas huérfanas sin pago o datos corruptos.

### B. Control y Gestión de Perfiles
Un usuario puede crear múltiples perfiles para los miembros de su hogar, permitiendo que cada uno tenga sus propios favoritos, historial y recomendaciones personalizadas.
*   **Flujo Técnico:** Al intentar crear un nuevo perfil, un disparador (`TRG_LIMITE_PERFILES`) intercepta la inserción y valida la cantidad de perfiles actuales contra el límite permitido por su plan (`PLANES.max_perfiles`). Si supera el límite, se cancela la inserción mediante una excepción personalizada. Al cambiar de plan (`SP_CAMBIAR_PLAN`), el sistema valida que los perfiles ya creados no excedan el límite del nuevo plan antes de proceder con el cambio y de registrar el movimiento en `HISTORIAL_PLANES`.

### C. Consumo y Seguimiento de Reproducciones (Tracking de Avance)
Cuando un perfil inicia un video o pista de audio, la aplicación registra el evento para permitir la funcionalidad "Continuar viendo" y calcular recomendaciones personalizadas.
*   **Flujo Técnico:** Al iniciar, se inserta una fila en `REPRODUCCIONES` con `fecha_hora_inicio` y un trigger (`TRG_VERIFICAR_CUENTA_ACTIVA`) verifica que el usuario de ese perfil tenga su cuenta en estado `ACTIVO`. Mientras el usuario reproduce, el porcentaje de avance se actualiza en la base de datos. Si el avance alcanza el 90% o más, un proceso en lote calcula de forma asíncrona la popularidad del contenido (`CONTENIDO.popularidad`), sumando las reproducciones completadas exitosamente.

### D. Programa de Fidelización por Referidos
Para fomentar el crecimiento orgánico, QuindioFlix otorga un 10% de descuento en la siguiente mensualidad tanto al usuario que refiere (Referidor) como al nuevo usuario registrado (Referido).
*   **Flujo Técnico:** Al registrarse el nuevo usuario con el código de su referidor, se inserta una fila en `DESCUENTOS_REFERIDOS` en estado `PENDIENTE`. Cuando el sistema corre la facturación mensual masiva, detecta si hay descuentos pendientes aplicables a los involucrados, calcula el monto final mediante la función `FN_CALCULAR_MONTO`, aplica el descuento y actualiza el estado del registro a `APLICADO`.

### E. Moderación y Reporte de Contenidos
Si un usuario considera que una escena o parte de un contenido infringe las políticas (por ejemplo, clasificación de edad incorrecta, lenguaje inapropiado), puede reportarlo.
*   **Flujo Técnico:** El perfil envía un reporte que se almacena en `REPORTES` con estado `PENDIENTE`. Un empleado del departamento de Soporte toma el caso (el estado pasa a `EN_REVISION` y se asigna su `id_empleado_moderador`). Tras la investigación, el moderador determina si el reporte es `RESUELTO` (por ejemplo, modificando la sinopsis o la clasificación de edad de la tabla `CONTENIDO` a través de un procedimiento) o `RECHAZADO`, registrando la justificación del cierre.

---

## 4. REGLAS DE NEGOCIO (MÍNIMO 10)
Las reglas de negocio son directrices obligatorias que rigen la operación de la empresa y que han sido codificadas en la estructura de la base de datos mediante restricciones DDL (`CHECK`, `UNIQUE`, `FOREIGN KEY`), disparadores (`TRIGGERS`) o procedimientos almacenados (`STORED PROCEDURES`):

1.  **Regla de Acceso por Estado de Cuenta (Frenado de Mora):** Un perfil solo puede reproducir contenido si el estado de la cuenta del suscriptor está marcado como `ACTIVO`. Si la cuenta está `INACTIVO` o `SUSPENDIDO`, el sistema bloquea inmediatamente la inserción en la tabla `REPRODUCCIONES` (Implementado vía trigger `TRG_VERIFICAR_CUENTA_ACTIVA`).
2.  **Regla de Límite de Perfiles por Plan:** El número total de perfiles activos en una cuenta de usuario no puede exceder la capacidad establecida por el plan contratado: Básico (máximo 2 perfiles), Estándar (máximo 3 perfiles) y Premium (máximo 5 perfiles) (Implementado vía trigger `TRG_LIMITE_PERFILES`).
3.  **Regla de Requisito Mínimo de Visualización para Calificar:** Un perfil solo puede calificar y dejar una reseña escrita sobre un contenido si ha reproducido al menos el 50% de su duración (Implementado vía trigger `TRG_VERIFICAR_REPROD_CALIF` leyendo la tabla `REPRODUCCIONES`).
4.  **Regla de Restricción de Degradación de Planes (Downgrade):** Un suscriptor no puede cambiarse a un plan inferior si el número de perfiles que tiene actualmente creados supera el límite máximo permitido por el nuevo plan de destino (Implementado vía validación lógica en el procedimiento `SP_CAMBIAR_PLAN`).
5.  **Regla de Control de Suscripción Vencida (Mora 30 Días):** Un usuario entra en estado moroso si han transcurrido más de 30 días calendario desde su último pago mensual exitoso registrado. Las cuentas en esta condición se extraen mediante consultas automatizadas para su suspensión (Implementado mediante cursor `c_usuarios_morosos` y proceso batch nocturno).
6.  **Regla de Tarifas Positivas:** El precio mensual de cualquier plan de suscripción registrado en la plataforma debe ser estrictamente mayor que cero pesos colombianos (Implementado vía restricción DDL `planes_precio_ck` en la tabla `PLANES`).
7.  **Regla de Rango de Avance de Reproducción:** El porcentaje de avance en cualquier reproducción debe ser un valor decimal comprendido obligatoriamente entre 0.00% y 100.00% (Implementado vía restricción DDL `repr_avance_ck` en la tabla `REPRODUCCIONES`).
8.  **Regla de Unicidad de Calificaciones:** Un perfil específico de usuario solo puede calificar un determinado contenido del catálogo una única vez en el sistema, impidiendo la manipulación fraudulenta de la popularidad de los títulos (Implementado vía clave única compuesta `calif_perfil_cont_uk` en la tabla `CALIFICACIONES`).
9.  **Regla de Prevención de Autorreferidos:** Un suscriptor no puede registrarse como referido de sí mismo, ni otorgar descuentos de programa de referidos a su propia cuenta (Implementado vía restricción DDL `desc_no_auto_ref` en la tabla `DESCUENTOS_REFERIDOS`).
10. **Regla de Prevención de Autoenlaces de Catálogo:** Un contenido multimedia no puede relacionarse consigo mismo como precuela, secuela, remake o spin-off (Implementado vía restricción DDL `cr_no_auto_ref` en la tabla `CONTENIDO_RELACIONADO`).
11. **Regla de Activación Automática por Pago:** Cuando se registra un pago mensual con estado `EXITOSO` para una cuenta que estaba suspendida o inactiva, su estado debe actualizarse automáticamente a `ACTIVO` y la fecha de último pago debe establecerse al día actual (Implementado vía trigger `TRG_PAGO_EXITOSO`).
12. **Regla de Consistencia en Temporadas de Contenido:** Un contenido del catálogo (Serie o Podcast) no puede tener dos temporadas registradas con el mismo número de orden (Implementado vía restricción de unicidad compuesta `temporadas_cont_num_uk` en la tabla `TEMPORADAS`).
13. **Regla de Consistencia en Episodios:** Una temporada específica de una serie o podcast no puede registrar dos episodios con el mismo número de orden correlativo (Implementado vía restricción de unicidad compuesta `episodios_temp_num_uk` en la tabla `EPISODIOS`).
14. **Regla de Calidad de Video Homologada:** La calidad máxima admitida en los planes de suscripción se limita estrictamente a los formatos comerciales estándar: 'SD' (definición estándar), 'HD' (alta definición) y '4K' (ultra alta definición) (Implementado vía restricción CHECK `planes_calidad_ck` en la tabla `PLANES`).
15. **Regla de Clasificación de Edad del Catálogo:** Todo contenido agregado al catálogo debe pertenecer obligatoriamente a una de las cinco clasificaciones de edad colombianas válidas: 'TP' (Todo Público), '+7', '+13', '+16', '+18' (Implementado vía restricción CHECK `contenido_clasif_ck` en la tabla `CONTENIDO`).

---

## 5. RESTRICCIONES DEL DOMINIO
Las restricciones del dominio especifican los límites, tipos de datos y formatos permitidos para las columnas individuales de las tablas:

*   **Valores No Nulos (`NOT NULL`):** Atributos fundamentales de negocio que no pueden quedar vacíos bajo ninguna circunstancia, tales como el `email` de un usuario, el `nombre_plan` de un plan, la `duracion_minutos` de un episodio, o las `estrellas` de una calificación.
*   **Identificadores Únicos (`UNIQUE`):** Campos lógicos que deben ser únicos globalmente, como el correo electrónico del suscriptor (`usuarios_email_uk`) para impedir registros duplicados, el correo de empleados (`empleados_email_uk`), o el nombre de las ciudades (`ciudades_nombre_uk`).
*   **Claves Primarias (`PRIMARY KEY`):** Identificadores numéricos generados secuencialmente que garantizan la identidad única de cada registro en las 20 tablas.
*   **Claves Foráneas (`FOREIGN KEY`):** Restricciones de integridad referencial que impiden el registro de datos huérfanos. Por ejemplo, no se puede registrar una reproducción para un perfil inexistente o un pago para un usuario eliminado.
*   **Tipos y Longitudes de Datos:**
    *   Nombres y títulos: Limitados en base a `VARCHAR2` entre `50` y `150` caracteres según el volumen.
    *   Sinopsis y reseñas: Definidas con `VARCHAR2(2000)` y `VARCHAR2(1000)` respectivamente para almacenar textos enriquecidos medianamente largos sin penalizar el almacenamiento.
    *   Campos monetarios: Definidos con precisión decimal `NUMBER(10,2)` para asegurar que no ocurran errores de redondeo de centavos en cobros y reportes financieros.
    *   Fechas y Horas: Representadas con `DATE` (para fechas simples de nacimiento o registro) y `TIMESTAMP` (para precisiones de milisegundos en el registro de inicio y fin de visualizaciones en la tabla `REPRODUCCIONES`).
