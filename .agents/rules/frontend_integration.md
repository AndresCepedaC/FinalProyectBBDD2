# Reglas de Integración Frontend-Backend

Este documento establece las directrices estrictas de arquitectura y contexto para el desarrollo y las modificaciones futuras en los archivos del Frontend (`app.js`, `index.html`, `styles.css`) y su interacción con el Backend desarrollado en Spring Boot (con soporte para Oracle/H2).

---

## 1. Conexión API
* **Uso de Fetch**: Todas las peticiones HTTP realizadas desde `app.js` hacia el backend deben implementarse obligatoriamente utilizando la API estándar de JavaScript `fetch()`.
* **Endpoints**: Las rutas utilizadas en las llamadas deben coincidir de forma exacta con los Endpoints expuestos por los controladores REST del backend (por ejemplo, `/api/auth/login`, `/api/catalogo`, etc.).

---

## 2. Manejo de Errores (PL/SQL y Excepciones)
* **Captura de Errores**: El backend implementa un `GlobalExceptionHandler` encargado de capturar y estructurar las excepciones de la base de datos (como fallos en triggers o denegación de acciones dentro de procedimientos almacenados como `SP_CAMBIAR_PLAN` al superar el límite de perfiles).
* **Propagación a la UI**: El Frontend debe leer siempre el cuerpo de la respuesta de error enviada por el servidor y mostrar el mensaje correspondiente al usuario final a través de elementos visuales en la interfaz gráfica (como `alert()`, `toast` o modales dinámicos).
* **Sin Silencios**: Queda estrictamente prohibido dejar que los errores fallen de manera silenciosa únicamente en la consola del navegador.

---

## 3. Seguridad
* **Almacenamiento de Sesión**: Los tokens de autenticación (JWT u otros) y los datos de sesión devueltos por `AuthController` deben almacenarse de forma segura en `sessionStorage` o `localStorage` según corresponda.
* **Cabeceras de Autorización**: Todas las solicitudes dirigidas a rutas protegidas por `SecurityConfig` en el backend deben incluir las cabeceras de autorización necesarias (por ejemplo, `Authorization: Bearer <token>`).

---

## 4. DTOs y Mapeos de Datos
* **Respetar la Estructura JSON**: El Frontend debe acoplarse y respetar fielmente las estructuras JSON devueltas por los Data Transfer Objects (DTOs) definidos en el backend (por ejemplo, `UsuarioResumenDTO`, `RegistroUsuarioDTO`, etc.) al momento de procesar y pintar la información en el DOM.

---

## 5. Diseño Visual y UX
* **Entorno de Streaming**: La interfaz gráfica de usuario debe simular un entorno de streaming moderno, responsivo y con temática oscura.
* **Estilos y DOM**: Se deben aplicar clases CSS claras, modulares y consistentes en `styles.css`. La manipulación del DOM debe responder dinámicamente de acuerdo con el rol y los permisos del usuario conectado (por ejemplo, adaptando las vistas y opciones entre Administrador y Usuario regular).
