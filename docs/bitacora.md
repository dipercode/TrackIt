# 📝 Bitácora de Desarrollo — TrackIt

Historial cronológico del diseño, desarrollo e implementación del ecosistema **TrackIt** (Backend Django + App Móvil Flutter).

---

## 📅 Enero 2026

### 🛠️ 2026-01-03 — Inicialización del Proyecto y Arquitectura
* **[Repo]** Creación del repositorio oficial `TrackIt` en GitHub e inclusión del archivo base `README.md`.
* **[Estrategia]** Definición de los objetivos generales del proyecto y selección del stack tecnológico: **Django REST Framework** para el backend y **Flutter** para la aplicación móvil.
* **[Backend]** Creación del directorio base de desarrollo para el backend.
* **[Diseño]** Modelado inicial del esquema de datos, identificando las entidades principales (Estaciones, Ubicaciones, Activos, Movimientos) y sus respectivas relaciones de negocio.

### 🔌 2026-01-09 — Configuración de la API REST Base
* **[Backend]** Creación y registro de la aplicación interna `assets` en la configuración de Django.
* **[API]** Exposición de los endpoints REST iniciales para la gestión de activos.
* **[API]** Ampliación de las rutas para dar soporte a las entidades de ubicaciones y movimientos.
* **[Fix]** Corrección de errores de enrutamiento en la aplicación `assets` y validación de respuestas JSON de la API.
* **[Seguridad]** Configuración de políticas CORS en el backend para habilitar de forma segura el consumo de datos desde la app móvil en Flutter.

### 🗄️ 2026-01-13 — Persistencia de Datos y Multi-Estación
* **[DB]** Instalación, configuración y conexión de **PostgreSQL** como motor de base de datos principal de Django.
* **[DB]** Creación y ejecución de las migraciones iniciales para reflejar el modelo de datos en PostgreSQL.
* **[Backend]** Desarrollo de serializers en Django REST Framework para asegurar un correcto intercambio de datos JSON.
* **[Backend]** Modificación estructural de la lógica de base de datos para segmentar y gestionar de manera independiente los activos distribuidos entre **3 estaciones de ITV**.
* **[API]** Habilitación provisional de acceso público a los endpoints mediante la desactivación temporal de la autenticación para agilizar pruebas locales.

---

## 📅 Abril 2026

### 📱 2026-04-01 — Maquetación de la App y Filtros del Servidor
* **[App]** Inicio oficial del desarrollo de la interfaz móvil en Flutter.
* **[App]** Implementación del sistema de navegación funcional entre la pantalla de Estaciones y sus respectivas Ubicaciones internas.
* **[App]** Refactorización y centralización de peticiones HTTP mediante la creación de la clase `ApiService`.
* **[UI]** Optimización visual en las listas de la app mediante la implementación de `ListView.separated` y la aplicación de la paleta de colores del tema.
* **[Backend]** Modificación y optimización del `ViewSet` de Ubicaciones para permitir el filtrado dinámico mediante el ID de la estación apoyado en `django-filter`.

### 🔍 2026-04-20 — Búsquedas Globales y Gestión de Estado
* **[Backend]** Activación de `SearchFilter` en Django para dar soporte nativo a búsquedas de texto indexadas y parciales.
* **[App]** Implementación de la barra de búsqueda global integrada en la interfaz mediante un `SearchDelegate`.
* **[App]** Diseño e integración de filtros rápidos por estados en las pantallas de Ubicaciones y Activos mediante el uso de `ChoiceChips`.
* **[App]** Desarrollo de la **Vista Global de Estación**, permitiendo a los usuarios inspeccionar y filtrar todos los activos pertenecientes a una misma estación sin necesidad de navegar ubicación por ubicación.
* **[API]** Inclusión del campo `ubicacion_nombre` dentro de la carga útil del JSON para robustecer la trazabilidad visual de los activos en las listas generales.

### 🎨 2026-04-23 — Refactorización de Red y Rediseño Visual
* **[Backend]** Refactorización completa del método `getActivos` utilizando las utilidades `Uri` y `queryParameters`. Esta corrección eliminó caracteres residuales (como un `&` huérfano en las concatenaciones de texto plano) que provocaban que el servidor ignorase los filtros y devolviese datos erróneos.
* **[UI]** Actualización integral de los estilos, fuentes y paleta de colores de la aplicación móvil.
* **[App]** Implementación de una lupa en la barra superior para activar búsquedas rápidas de activos específicos por nombre.

### 🔐 2026-04-29 — Autenticación y Control de Sesión
* **[Backend]** Implementación del módulo `authtoken` de Django para el aprovisionamiento de credenciales de inicio de sesión seguras.
* **[App]** Integración de la lógica de Login guardando de forma persistente el token de usuario a través de `shared_preferences`.
* **[App]** Desarrollo del proceso de cierre de sesión (`logout`) junto con un modal de confirmación UI interactivo.
* **[App]** Modificación estructural de `main.dart` para evaluar de manera condicional la ruta de arranque (pantalla de autenticación frente a pantalla de inicio) según la presencia del token.

---

## 📅 Mayo 2026

### 🚀 2026-05-11 — Pruebas en Hardware Real y Configuración de Red
* **[Despliegue]** Migración exitosa del entorno de simulación local del emulador a la ejecución directa en hardware real (**Redmi Note 8 Pro**).
* **[Red]** Configuración de un entorno de red local compartida mediante IP estática y apertura del servidor de desarrollo de Django apuntando al puerto `0.0.0.0`.
* **[Seguridad]** Resolución de errores críticos `CSRF 403` en la comunicación móvil mediante la creación de una vista puente con el decorador `@csrf_exempt` y ajustes personalizados en los Middlewares del servidor.
* **[Módulo]** Validación completa de todo el flujo de recuperación de contraseñas (Envío del token mediante SMTP seguro de Gmail ➡️ interfaz web de restablecimiento ➡️ cambio de credenciales en DB ➡️ login exitoso desde la App).

### 🔔 2026-05-25 — Alertas Preventivas, Módulo de Impresión QR y Refactorización UI
* **[Backend]** Análisis y detección de exclusiones en el endpoint `getActivosUrgentes()`, el cual discriminaba datos en el servidor debido al parámetro estricto `?vencidos=true`.
* **[API]** Creación del nuevo método `ApiService.getActivosProximos()` para descargar el catálogo de activos y permitir una evaluación de fechas preventiva en el cliente.
* **[App]** Optimización matemática en los filtros de fecha de Flutter. Se normalizaron las instancias de `DateTime` omitiendo las horas y milisegundos (`year, month, day`) para evitar desfases de zona horaria durante los cálculos.
* **[QR]** **Implementación del Módulo de Impresión:** Se desarrolló la funcionalidad para la generación y maquetación de códigos QR optimizados para su impresión física, permitiendo el etiquetado e identificación en campo de cada activo.
* **[UI]** Corrección e implementación del banner de **PREVENCIÓN (Ámbar)**, capturando perfectamente los activos que se encuentran dentro del rango crítico de 15 días previos a su vencimiento de calibración.
* **[UI]** Rediseño estético total del banner de **URGENCIAS (Rojo)** adoptando un formato de **alto contraste** sólido (`0xFFFFF1F2`), bordes rígidos y tipografías oscuras profundas que igualan la jerarquía visual del banner preventivo y garantizan la máxima accesibilidad.
* **[Seguridad & Auditoría]** Se solucionó un problema de hardcoding en el registro de transferencias de Flutter. Se eliminó el ID de usuario estático (`"usuario": 1`) en favor del método `perform_create` en el `MovimientoViewSet` de Django, resolviendo la autoría del movimiento dinámicamente mediante el Token del usuario logueado (`request.user`).