import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8000/api"; // IP para emulador Android
  
  // VARIABLE: Para construir las rutas completas de las imágenes de Django de forma dinámica
  static const String mediaUrl = "http://10.0.2.2:8000"; 

  // Función auxiliar para obtener cabeceras con Token
  static Future<Map<String, String>> _getHeaders() async {
    String? token = await AuthService.getToken();
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Token $token",
    };
  }

  static Future<List<dynamic>> getEstaciones() async {
    final response = await http.get(
      Uri.parse("$baseUrl/estaciones/"),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Error cargando estaciones");
    }
  }

  static Future<List<dynamic>> getUbicaciones(int estacionId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/ubicaciones/?estacion=$estacionId"),
      headers: await _getHeaders(),
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
    Map<String, String> params = {};
    if (ubicacionId != null) params['ubicacion'] = ubicacionId.toString();
    if (estacionId != null) params['ubicacion__estacion'] = estacionId.toString();
    if (estado != null && estado != "TODOS") params['estado'] = estado;

    final uri = Uri.parse("$baseUrl/activos/").replace(queryParameters: params);

    try {
      final response = await http.get(uri, headers: await _getHeaders());
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al cargar activos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<List<dynamic>> getMovimientosActivo(int activoId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/activos/$activoId/movimientos/"),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Error al cargar el historial de movimientos");
    }
  }

  static Future<bool> registrarMovimiento(int activoId, int destinoId, String tipo, String motivo) async {
    final response = await http.post(
      Uri.parse("$baseUrl/movimientos/"),
      headers: await _getHeaders(),
      body: json.encode({
        "activo": activoId,
        "ubicacion_destino": destinoId,
        "tipo": tipo,
        "motivo": motivo,
        "usuario": 1, 
      }),
    );
    return response.statusCode == 201;
  }

  static Future<List<dynamic>> getTodasLasUbicaciones() async {
    final response = await http.get(
      Uri.parse("$baseUrl/ubicaciones/"),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Error al cargar todas las ubicaciones");
    }
  }

  static Future<List<dynamic>> buscarActivos(String query) async {
    if (query.trim().isEmpty) return [];
    final response = await http.get(
      Uri.parse('$baseUrl/activos/?search=${Uri.encodeComponent(query)}'),
      headers: await _getHeaders(),
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
      headers: await _getHeaders(),
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
    File? imagenCalibracion,
    String? fechaProximaVerificacion,
  }) async {
    var request = http.MultipartRequest('POST', Uri.parse("$baseUrl/activos/"));
    
    String? token = await AuthService.getToken();
    if (token != null) request.headers['Authorization'] = "Token $token";

    request.fields['nombre'] = nombre;
    request.fields['descripcion'] = descripcion;
    request.fields['ubicacion'] = ubicacionId.toString();
    request.fields['estado'] = estado;

    if (fechaProximaVerificacion != null) {
      request.fields['fecha_proxima_verificacion'] = fechaProximaVerificacion;
      request.fields['requiere_calibracion'] = 'true';
    }

    if (imagen != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'imagen',
        imagen.path,
        contentType: MediaType('image', 'jpeg'),
      ));
    }

    if (imagenCalibracion != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'imagen_calibracion',
        imagenCalibracion.path,
        contentType: MediaType('image', 'jpeg'),
      ));
    }

    var response = await request.send();
    return response.statusCode == 201;
  }

  static Future<bool> actualizarActivo({
    required int id,
    required String nombre,
    required String descripcion,
    required String estado,
    required int ubicacionId,
    String? fechaProximaVerificacion,
    bool? requiereCalibracion,
    String? codigoQr,
    File? imagenCalibracion,
  }) async {
    try {
      var request = http.MultipartRequest('PATCH', Uri.parse('$baseUrl/activos/$id/'));
      
      String? token = await AuthService.getToken();
      if (token != null) request.headers['Authorization'] = "Token $token";

      request.fields['nombre'] = nombre;
      request.fields['descripcion'] = descripcion;
      request.fields['estado'] = estado;
      request.fields['ubicacion'] = ubicacionId.toString();
      if (fechaProximaVerificacion != null) {
        request.fields['fecha_proxima_verificacion'] = fechaProximaVerificacion;
      }
      if (requiereCalibracion != null) {
        request.fields['requiere_calibracion'] = requiereCalibracion.toString();
      }
      if (codigoQr != null) {
        request.fields['codigo_qr'] = codigoQr;
      }

      if (imagenCalibracion != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'imagen_calibracion',
          imagenCalibracion.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      var streamedResponse = await request.send();
      return streamedResponse.statusCode == 200;
    } catch (e) {
      debugPrint("Error en actualizarActivo: $e");
      return false;
    }
  }

  static Future<bool> crearUbicacion(String nombre) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ubicaciones/'),
        headers: await _getHeaders(),
        body: jsonEncode({'nombre': nombre}),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> crearEstacion(String nombre) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/estaciones/'),
        headers: await _getHeaders(),
        body: jsonEncode({'nombre': nombre}),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      debugPrint("Error en crearEstacion: $e");
      return false;
    }
  }

  static Future<Map<String, dynamic>?> obtenerActivo(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/activos/$id/'),
        headers: await _getHeaders()
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint("Error al obtener activo: $e");
      return null;
    }
  }

  static Future<List<dynamic>> getActivosUrgentes() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/activos/?vencidos=true"),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("Error en getActivosUrgentes: $e");
      return [];
    }
  }

  // MÉTODO: Trae el listado completo de activos de la base de datos 
  // para que Flutter pueda evaluar preventivamente cuáles vencen en los próximos 15 días.
  static Future<List<dynamic>> getActivosProximos() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/activos/"),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("Error en getActivosProximos: $e");
      return [];
    }
  }
}