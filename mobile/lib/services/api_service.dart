
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
}