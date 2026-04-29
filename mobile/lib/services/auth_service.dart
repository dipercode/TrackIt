import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // La base URL ya incluye el /api
  static const String baseUrl = "http://10.0.2.2:8000/api";

  // Iniciar sesión con el endpoint correcto de Django
  static Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        // CAMBIO: Ahora apunta a /api/login/ según tu urls.py
        Uri.parse("$baseUrl/login/"), 
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username, 
          "password": password
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // obtain_auth_token devuelve la clave en el campo 'token'
        final token = data['token'];
        
        // Guardar token localmente
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        
        return true;
      } else {
        // Imprime el error en consola para debuguear si falla (ej. 400 Bad Request)
        print("Error en login: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error de conexión: $e");
      return false;
    }
  }

  // Obtener el token guardado para las peticiones de ApiService
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Cerrar sesión
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}