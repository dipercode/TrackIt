Documentación de la API REST – TrackIt
1. Introducción

Este documento describe la API REST del sistema TrackIt, desarrollada con Django REST Framework, cuyo objetivo es permitir la gestión de activos en estaciones de Inspección Técnica de Vehículos (ITV).

La API proporciona endpoints para la administración de estaciones, ubicaciones, activos y movimientos, permitiendo la trazabilidad completa de los equipos y las acciones realizadas sobre ellos.

Durante la fase de desarrollo, la autenticación se encuentra desactivada para facilitar las pruebas y validación de los endpoints.

2. Convenciones generales

Formato de intercambio de datos: JSON

Base URL:

http://127.0.0.1:8000/api/

Métodos HTTP utilizados:

GET: Consulta de información

POST: Creación de nuevos registros

PUT / PATCH: Modificación de registros existentes

DELETE: Eliminación de registros

3. Endpoint: Estaciones
3.1 Listar estaciones

GET /estaciones/

Devuelve el listado de estaciones ITV registradas en el sistema.

Ejemplo de respuesta:

[
  {
    "id": 1,
    "nombre": "Mayorazgo",
    "descripcion": "Estación ITV Mayorazgo"
  }
]

3.2 Crear estación

POST /estaciones/

Permite registrar una nueva estación ITV.

Ejemplo de petición:

{
  "nombre": "La Cuesta",
  "descripcion": "Estación ITV La Cuesta"
}

4. Endpoint: Ubicaciones
4.1 Listar ubicaciones

GET /ubicaciones/

Devuelve el listado de ubicaciones disponibles, indicando la estación a la que pertenecen.

Ejemplo de respuesta:

[
  {
    "id": 1,
    "nombre": "Línea 1",
    "estacion": 1
  }
]

4.2 Crear ubicación

POST /ubicaciones/

Permite crear una nueva ubicación asociada a una estación.

Ejemplo de petición:

{
  "nombre": "Almacén",
  "estacion": 1
}

5. Endpoint: Activos
5.1 Listar activos

GET /activos/

Devuelve el listado de activos registrados junto con su ubicación.

Ejemplo de respuesta:

[
  {
    "id": 1,
    "nombre": "Frenómetro",
    "descripcion": "Equipo de medición de frenado",
    "codigo_qr": "ITV-MAY-FRENO-01",
    "estado": "Operativo",
    "ubicacion": {
      "id": 1,
      "nombre": "Línea 1",
      "estacion": 1
    }
  }
]

5.2 Crear activo

POST /activos/

Permite registrar un nuevo activo en una ubicación concreta.

Ejemplo de petición:

{
  "nombre": "Analizador de gases",
  "descripcion": "Equipo de medición de emisiones",
  "codigo_qr": "ITV-MAY-GAS-01",
  "estado": "Operativo",
  "ubicacion": 1
}

6. Endpoint: Movimientos
6.1 Listar movimientos

GET /movimientos/

Devuelve el historial de movimientos realizados sobre los activos.

6.2 Crear movimiento

POST /movimientos/

Permite registrar una acción realizada sobre un activo, asociándola a un usuario.

Ejemplo de petición:

{
  "activo": 1,
  "usuario": 1,
  "tipo": "MANTENIMIENTO",
  "observaciones": "Calibración periódica del equipo"
}

7. Gestión de usuarios

La API utiliza el sistema de usuarios integrado de Django para identificar a las personas que realizan acciones sobre los activos.

Los usuarios se gestionan desde el panel de administración y se asocian a los movimientos para garantizar la trazabilidad.

8. Consideraciones de seguridad

Durante la fase de desarrollo, los endpoints de la API REST no requieren autenticación. En una fase posterior del proyecto se prevé la activación de autenticación mediante token para controlar el acceso a la API.

9. Conclusión

La API REST de TrackIt proporciona una interfaz clara y estructurada para la gestión de activos en estaciones ITV, permitiendo su integración con aplicaciones web y móviles, y garantizando la trazabilidad de las acciones realizadas sobre los equipos.