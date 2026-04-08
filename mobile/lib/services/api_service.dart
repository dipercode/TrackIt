
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

  static Future<List<dynamic>> getActivos(int ubicacionId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/activos/?ubicacion=$ubicacionId")
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Error al cargar los activos");
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

}