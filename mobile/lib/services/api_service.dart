
import 'dart:convert';
import 'package:http/http.dart' as http;

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
    String url = '$baseUrl/activos/?';

    // Si queremos filtrar por una ubicación específica
    if (ubicacionId != null) {
      url += 'ubicacion=$ubicacionId&';
    }

    // Si queremos filtrar por toda la estación
    if (estacionId != null) {
      url += 'ubicacion__estacion=$estacionId&';
    }

    // Si seleccionamos un estado (Averiado, Operativo, etc)
    if (estado != null) {
      url += 'estado=$estado';
    }

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al cargar activos');
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

}