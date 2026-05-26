# QUINDIOFLIX - MODELO ENTIDAD-RELACIÓN (MER)
## Proyecto Final - Bases de Datos II
### Universidad del Quindío

---

## 1. PRESENTACIÓN DEL MODELO
El Modelo Entidad-Relación (MER) de QuindioFlix consta de **20 entidades** perfectamente normalizadas e interconectadas. Este diseño soporta toda la lógica de la aplicación de streaming, garantizando la consistencia y eliminando la redundancia de datos.

A continuación se detalla el diagrama relacional completo en formato **Mermaid.js**, un estándar de modelado de texto moderno e interactivo que puede renderizarse directamente en múltiples herramientas y exportarse en alta definición a **PNG o PDF**.

---

## 2. DIAGRAMA ENTIDAD-RELACIÓN COMPLETO (Mermaid.js)

```mermaid
erDiagram
    PLANES ||--o{ USUARIOS : "id_plan"
    CIUDADES ||--o{ USUARIOS : "id_ciudad"
    USUARIOS |o--o{ USUARIOS : "id_referidor (self-ref)"
    USUARIOS ||--o{ PERFILES : "id_usuario"
    USUARIOS ||--o{ PAGOS : "id_usuario"
    USUARIOS ||--o{ HISTORIAL_PLANES : "id_usuario"
    PLANES ||--o{ HISTORIAL_PLANES : "id_plan_anterior"
    PLANES ||--o{ HISTORIAL_PLANES : "id_plan_nuevo"
    USUARIOS ||--o{ DESCUENTOS_REFERIDOS : "id_usuario_referidor"
    USUARIOS ||--o{ DESCUENTOS_REFERIDOS : "id_usuario_referido"
    
    DEPARTAMENTOS ||--o{ EMPLEADOS : "id_departamento"
    EMPLEADOS ||--o{ EMPLEADOS : "id_supervisor (self-ref)"
    EMPLEADOS |o--o| DEPARTAMENTOS : "id_empleado_jefe"
    EMPLEADOS ||--o{ CONTENIDO : "id_empleado_publicador"
    EMPLEADOS ||--o{ REPORTES : "id_empleado_moderador"
    
    CATEGORIAS ||--o{ CONTENIDO : "id_categoria"
    CONTENIDO ||--o{ CONTENIDO_GENERO : "id_contenido"
    GENEROS ||--o{ CONTENIDO_GENERO : "id_genero"
    CONTENIDO ||--o{ TEMPORADAS : "id_contenido"
    TEMPORADAS ||--o{ EPISODIOS : "id_temporada"
    CONTENIDO ||--o{ CONTENIDO_RELACIONADO : "id_contenido_origen"
    CONTENIDO ||--o{ CONTENIDO_RELACIONADO : "id_contenido_destino"
    
    PERFILES ||--o{ REPRODUCCIONES : "id_perfil"
    CONTENIDO ||--o{ REPRODUCCIONES : "id_contenido"
    EPISODIOS |o--o{ REPRODUCCIONES : "id_episodio"
    
    PERFILES ||--o{ CALIFICACIONES : "id_perfil"
    CONTENIDO ||--o{ CALIFICACIONES : "id_contenido"
    
    PERFILES ||--o{ FAVORITOS : "id_perfil"
    CONTENIDO ||--o{ FAVORITOS : "id_contenido"
    
    PERFILES ||--o{ REPORTES : "id_perfil"
    CONTENIDO ||--o{ REPORTES : "id_contenido"

    PLANES {
        NUMBER id_plan PK
        VARCHAR2 nombre_plan UK
        NUMBER limite_pantallas
        NUMBER max_perfiles
        VARCHAR2 calidad
        NUMBER precio_mensual
    }
    CIUDADES {
        NUMBER id_ciudad PK
        VARCHAR2 nombre_ciudad UK
    }
    USUARIOS {
        NUMBER id_usuario PK
        NUMBER id_plan FK
        NUMBER id_ciudad FK
        NUMBER id_referidor FK "self-ref"
        VARCHAR2 nombre_completo
        VARCHAR2 email UK
        VARCHAR2 contrasena_hash
        VARCHAR2 telefono
        DATE fecha_nacimiento
        DATE fecha_registro
        VARCHAR2 estado_cuenta
        DATE fecha_ultimo_pago
    }
    PERFILES {
        NUMBER id_perfil PK
        NUMBER id_usuario FK
        VARCHAR2 nombre_perfil
        VARCHAR2 avatar
        VARCHAR2 tipo_perfil
        DATE fecha_creacion
    }
    CATEGORIAS {
        NUMBER id_categoria PK
        VARCHAR2 nombre_categoria UK
    }
    GENEROS {
        NUMBER id_genero PK
        VARCHAR2 nombre_genero UK
    }
    CONTENIDO {
        NUMBER id_contenido PK
        NUMBER id_categoria FK
        NUMBER id_empleado_publicador FK
        VARCHAR2 titulo
        NUMBER ano_lanzamiento
        NUMBER duracion_minutos
        VARCHAR2 sinopsis
        VARCHAR2 clasificacion_edad
        DATE fecha_agregado
        NUMBER es_original
        NUMBER popularidad
        VARCHAR2 estado
    }
    CONTENIDO_GENERO {
        NUMBER id_contenido PK_FK
        NUMBER id_genero PK_FK
    }
    TEMPORADAS {
        NUMBER id_temporada PK
        NUMBER id_contenido FK
        NUMBER numero_temporada
    }
    EPISODIOS {
        NUMBER id_episodio PK
        NUMBER id_temporada FK
        NUMBER numero_episodio
        VARCHAR2 titulo_episodio
        NUMBER duracion_minutos
    }
    CONTENIDO_RELACIONADO {
        NUMBER id_contenido_origen PK_FK
        NUMBER id_contenido_destino PK_FK
        VARCHAR2 tipo_relacion
    }
    DEPARTAMENTOS {
        NUMBER id_departamento PK
        VARCHAR2 nombre_departamento UK
        NUMBER id_empleado_jefe FK
    }
    EMPLEADOS {
        NUMBER id_empleado PK
        NUMBER id_departamento FK
        NUMBER id_supervisor FK "self-ref"
        VARCHAR2 nombre_empleado
        VARCHAR2 email_empleado UK
        VARCHAR2 rol_empleado
        DATE fecha_contratacion
    }
    REPRODUCCIONES {
        NUMBER id_reproduccion PK
        NUMBER id_perfil FK
        NUMBER id_contenido FK
        NUMBER id_episodio FK
        TIMESTAMP fecha_hora_inicio
        TIMESTAMP fecha_hora_fin
        VARCHAR2 dispositivo
        NUMBER porcentaje_avance
    }
    CALIFICACIONES {
        NUMBER id_calificacion PK
        NUMBER id_perfil FK
        NUMBER id_contenido FK
        NUMBER estrellas
        VARCHAR2 resena
        DATE fecha_calificacion
    }
    FAVORITOS {
        NUMBER id_favorito PK
        NUMBER id_perfil FK
        NUMBER id_contenido FK
        DATE fecha_agregado
    }
    REPORTES {
        NUMBER id_reporte PK
        NUMBER id_perfil FK
        NUMBER id_contenido FK
        NUMBER id_empleado_moderador FK
        VARCHAR2 descripcion_reporte
        VARCHAR2 estado_reporte
        VARCHAR2 resolucion_descripcion
        DATE fecha_reporte
        DATE fecha_resolucion
    }
    PAGOS {
        NUMBER id_pago PK
        NUMBER id_usuario FK
        DATE fecha_pago
        DATE fecha_vencimiento
        NUMBER monto
        VARCHAR2 metodo_pago
        VARCHAR2 estado_pago
    }
    HISTORIAL_PLANES {
        NUMBER id_historial PK
        NUMBER id_usuario FK
        NUMBER id_plan_anterior FK
        NUMBER id_plan_nuevo FK
        DATE fecha_cambio
        VARCHAR2 motivo
    }
    DESCUENTOS_REFERIDOS {
        NUMBER id_descuento PK
        NUMBER id_usuario_referidor FK
        NUMBER id_usuario_referido FK
        NUMBER porcentaje_descuento
        VARCHAR2 estado
        DATE fecha_aplicacion
    }
```

---

## 3. INSTRUCCIONES DE EXPORTACIÓN (Para obtener PNG o PDF Profesional)
Para presentar este diagrama en la sustentación final y en los entregables físicos (Word/PDF) con una calidad óptima y vectorizada, siga estos sencillos pasos:

### Opción A: A través de Mermaid Live Editor (Recomendado)
1.  Copie el bloque de código de arriba (desde `erDiagram` hasta el corchete de cierre del final).
2.  Abra su navegador de internet e ingrese al editor oficial en línea: **[mermaid.live](https://mermaid.live)**.
3.  Pegue el código copiado en el panel izquierdo titulado **"Code"**.
4.  El diagrama se renderizará automáticamente en tiempo real en la pantalla derecha en un lienzo interactivo de alta resolución.
5.  En el panel izquierdo inferior, haga clic en el botón **"Actions"**:
    *   Para **PNG**: Haga clic en **"PNG"** para descargar la imagen en alta definición.
    *   Para **PDF**: Haga clic en **"SVG"** (formato vectorial), ábralo en su navegador de preferencia y seleccione la opción "Imprimir como PDF", o use un conversor online de SVG a PDF para obtener un documento nítido y sin pérdida de calidad al hacer zoom.

### Opción B: A través de VS Code (Con extensiones de Markdown)
1.  Si está visualizando este archivo dentro de **Visual Studio Code**, asegúrese de tener instalada la extensión **"Markdown Preview Mermaid Support"** o **"Mermaid Preview"**.
2.  Presione `Ctrl + Shift + V` para abrir la vista previa de este archivo Markdown. El diagrama se dibujará de forma totalmente nativa en la pantalla.
3.  Haga clic derecho en el diagrama y seleccione la opción **"Save Diagram As"** para guardarlo como PNG en su computadora.
