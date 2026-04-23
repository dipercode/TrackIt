
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:io';


class ApiService {
  static const String baseUrl = "http://10.0.2.2:8000/api";

  static Future<List<dynamic>> getEstaciones() async {
    final response = await http.get(
      Uri.parse("$baseUrl/estaciones/")
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Error cargando estaciones");
    }
  }

  static Future<List<dynamic>> getUbicaciones(int estacionId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/ubicaciones/?estacion=$estacionId")
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Error al cargar ubicaciones");
    }
  }

  static Future<List<dynamic>> getActivos({
    int? ubicacionId, 
    int? estacionId, 
    String? estado
  }) async {
    // Creamos un mapa con los parámetros que realmente existen
    Map<String, String> params = {};

    if (ubicacionId != null) params['ubicacion'] = ubicacionId.toString();
    if (estacionId != null) params['ubicacion__estacion'] = estacionId.toString();
    if (estado != null && estado != "TODOS") params['estado'] = estado;

    // Usamos Uri para construir la URL de forma profesional (maneja los ? y & por nosotros)
    final uri = Uri.parse("$baseUrl/activos/").replace(queryParameters: params);

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al cargar activos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener un solo activo por su ID
  static Future<Map<String, dynamic>> getActivoDetalle(int activoId) async {
    final response = await http.get(Uri.parse("$baseUrl/activos/$activoId/"));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Error al cargar el detalle del activo");
    }
  }

  // Obtener los movimientos de un activo (Usando @action de Django)
  static Future<List<dynamic>> getMovimientosActivo(int activoId) async {
    final response = await http.get(Uri.parse("$baseUrl/activos/$activoId/movimientos/"));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Error al cargar el historial de movimientos");
    }
  }


  static Future<bool> registrarMovimiento(int activoId, int destinoId, String tipo, String motivo) async {
    final response = await http.post(
      Uri.parse("$baseUrl/movimientos/"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "activo": activoId,
        "ubicacion_destino": destinoId,
        "tipo": tipo,
        "motivo": motivo,
        "usuario": 1, 
      }),
    );

    return response.statusCode == 201; // 201 es "Created"
  }

  static Future<List<dynamic>> getTodasLasUbicaciones() async {
    final response = await http.get(Uri.parse("$baseUrl/ubicaciones/"));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Error al cargar todas las ubicaciones");
    }
  }

  static Future<List<dynamic>> buscarActivos(String query) async {
  // 1. Si la query está vacía, no molestamos al servidor y devolvemos lista vacía
    if (query.trim().isEmpty) {
      return [];
    }
    
    final response = await http.get(
      Uri.parse('$baseUrl/activos/?search=${Uri.encodeComponent(query)}'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al buscar activos');
    }
  }


  static Future<bool> actualizarEstadoActivo(int activoId, String nuevoEstado) async {
    final response = await http.patch(
      Uri.parse("$baseUrl/activos/$activoId/"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"estado": nuevoEstado}),
    );

    return response.statusCode == 200;
  }

  static Future<bool> crearActivo({
    required String nombre,
    required String descripcion,
    required int ubicacionId,
    required String estado,
    File? imagen,
    String? fechaProximaVerificacion,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("$baseUrl/activos/"),
    );

    // Campos de texto
    request.fields['nombre'] = nombre;
    request.fields['descripcion'] = descripcion;
    request.fields['ubicacion'] = ubicacionId.toString();
    request.fields['estado'] = estado;
    if (fechaProximaVerificacion != null) {
      request.fields['fecha_proxima_verificacion'] = fechaProximaVerificacion;
    }

    // Adjuntar imagen si existe
    if (imagen != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'imagen',
        imagen.path,
        contentType: MediaType('image', 'jpeg'),
      ));
    }

    var response = await request.send();
    return response.statusCode == 201;
  }


}