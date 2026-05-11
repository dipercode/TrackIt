# Bitácora de Desarrollo – TrackIt

## 2026-01-03

* Creación del repositorio TrackIt en GitHub.
* Primer commit con el archivo README.md.
* Definición inicial del proyecto y su objetivo general.

## 2026-01-03

* Creación de la carpeta backend como base del desarrollo técnico.
* Redacción de la descripción del proyecto.
* Revisión y actualización de la documentación del proyecto.
* Decisión de utilizar Flutter para el desarrollo de la aplicación móvil.

## 2026-01-03

* Definición del modelo de datos del sistema TrackIt.
* Identificación de entidades principales y sus relaciones.

## 2026-01-09

* Creación de la aplicación assets en el backend Django.
* Registro de la app assets en la configuración del proyecto.

## 2026-01-09

* Corrección de error en el archivo de rutas de la app assets.
* Verificación del funcionamiento de la API REST de activos.

## 2026-01-09

* Ampliación de la API REST para incluir ubicaciones y movimientos.
* Exposición de endpoints REST para todas las entidades principales del sistema.

## 2026-01-09

* Configuración de CORS para permitir el consumo de la API desde aplicación móvil.
* Preparación del backend para su integración con Flutter.

## 2026-01-13

* Instalación y configuración de PostgreSQL como base de datos del proyecto.
* Conexión del backend Django con PostgreSQL.
* Ejecución de migraciones iniciales.
* Verificación del funcionamiento mediante el panel de administración.
* Configuración inicial de la API REST con Django REST Framework.
* Habilitación de autenticación por token.
* Creación de los serializers para los modelos principales del sistema.
* Preparación de la API REST para el intercambio de datos en formato JSON.
* Desactivación temporal de la autenticación en la API REST para facilitar las pruebas
* Verificación del acceso público a los endpoints.
* Modificación de la DB para gestionar los activos entre las 3 estaciones de ITV.
* Definir ubicaciones y activos distribuidos entre las 3 estaciones.

## 2026-04-01

* Implementación de la navegación entre pantallas en Flutter.
* Creación de la vista de Ubicaciones filtrada por Estación.
* Conexión del ApiService con el endpoint de ubicaciones.

## 2026-04-01

* [App Móvil] Inicio del desarrollo de la interfaz en Flutter.
* [App Móvil] Implementación funcional de la navegación entre Estaciones y Ubicaciones internas.
* [App Móvil] Refactorización del ApiService para centralizar las llamadas al backend (Django).
* [App Móvil] Ajuste de UI: Se mejoró el diseño de las listas con ListView.separated y se aplicó tema de colores.
* [Backend] Ajuste en el ViewSet de Ubicaciones para permitir filtrado por ID de estación.
* [Backend] Verificado el filtrado de ubicaciones mediante django-filter.

## 2026-04-20

* [Backend] Optimización del backend (activación de SearchFilter) para soportar búsquedas parciales.
* [App Móvil] 
    - Implementación de búsqueda global (SearchDelegate).
    - Sistema de filtros por estados en las pantallas de Ubicaciones y Activos (ChoiceChips).
    - Vista glogal de estación: se ajustó el sistema para permitir ver todos los activos de una estación completa, filtrados por estado, sin necesidad de entrar ubicación por ubicación.
    - Mejora de serialización: se añadió el campo 'ubicacion_nombre' en el API para mejorar la trazabilidad visual en las listas globales.

## 2026-04-23

* [Backend] Se refactorizó getActivos utilizando la clase Uri y queryParameters. Esto eliminó errores de sintaxis en la URL (como el & huérfano) que causaban que el backend ignorara los filtros y devolviera la lista completa.
* [App Móvil] 
    - Cambio de las UI y paleta de colores.
    - Implementación de una lupa para buscar un activo por nombre.

## 2026-04-29

* [Backend] Implementación de authtoken para login seguro.
* [App Móvil]
    - Implementación de lógica de login, guardando el token mediante shared_preferences y método de limpieza de sesión (logout).
    - UX/UI: modificación de main.dart para arranque condicional (login vs home). Añadido botón de cierre de sesión con diálogo de confirmación en pantalla principal.

## 2026-05-11

* Despliegue en hardware real: Migración exitosa del entorno de pruebas del emulador al dispositivo físico (Redmi Note 8 Pro).
* Resolución de conectividad: Configuración de red local mediante IP estática y apertura del servidor Django en la red (0.0.0.0).
* Seguridad API: Resolución del error CSRF 403 mediante la implementación de una vista puente (@csrf_exempt) y ajuste del Middleware para compatibilidad con aplicaciones móviles.
* Flujo de recuperación de contraseña: Validación completa del ciclo de restablecimiento de contraseña (envío de email vía SMTP Gmail -> enlace web -> cambiko de clave -> login exitoso en App).