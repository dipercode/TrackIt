# Modelo de Datos – TrackIt

## 1. Introducción

Este documento describe el modelo de datos inicial del sistema TrackIt. El objetivo es definir las entidades principales, sus atributos y las relaciones entre ellas, sirviendo como base para la implementación de la base de datos y del backend.

---

## 2. Entidades principales

### 2.1. Activo

Representa cada activo físico que debe ser gestionado y trazado dentro del sistema.

**Atributos:**

* `id`: Identificador único del activo.
* `nombre`: Nombre descriptivo del activo.
* `descripcion`: Información adicional del activo.
* `codigo_qr`: Código único asociado al activo.
* `estado`: Estado actual del activo (Disponible, Asignado, Mantenimiento).
* `ubicacion`: Ubicación actual del activo.
* `fecha_ultimo_mantenimiento`: Fecha del último mantenimiento realizado.
* `fecha_creacion`: Fecha de alta del activo en el sistema.

---

### 2.2. Usuario

Representa a las personas que interactúan con el sistema.

**Atributos:**

* `id`: Identificador único del usuario.
* `nombre`: Nombre completo del usuario.
* `email`: Correo electrónico.
* `rol`: Rol del usuario (Administrador, Operador).
* `fecha_creacion`: Fecha de registro en el sistema.

---

### 2.3. Movimiento

Registra cada acción de salida o devolución de un activo.

**Atributos:**

* `id`: Identificador único del movimiento.
* `tipo`: Tipo de movimiento (Check-out, Check-in).
* `fecha_hora`: Fecha y hora del movimiento.
* `activo`: Referencia al activo afectado.
* `usuario`: Usuario que realiza la acción.

---

### 2.4. Ubicación

Define las posibles ubicaciones físicas donde pueden encontrarse los activos.

**Atributos:**

* `id`: Identificador único de la ubicación.
* `nombre`: Nombre de la ubicación.
* `descripcion`: Información adicional.

---

## 3. Relaciones entre entidades

* Un **Activo** puede tener múltiples **Movimientos** a lo largo del tiempo.
* Un **Movimiento** está asociado a un único **Activo** y a un único **Usuario**.
* Un **Usuario** puede realizar múltiples **Movimientos**.
* Un **Activo** puede estar asociado a una **Ubicación**.

---

## 4. Consideraciones iniciales

* El campo `codigo_qr` será único para cada activo y se utilizará como identificador en la aplicación móvil.
* El estado del activo se actualizará automáticamente en función de los movimientos registrados.
* El historial de movimientos permitirá consultar la trazabilidad completa de cada activo.

---

## 5. Evolución futura del modelo

El modelo de datos podrá ampliarse en futuras fases del proyecto para incluir:

* Gestión de alertas de mantenimiento.
* Historial de incidencias.
* Integración con tecnología NFC.
