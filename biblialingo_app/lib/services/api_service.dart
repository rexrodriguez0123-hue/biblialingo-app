import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Cambia esto a tu URL de Render una vez desplegado:
  // static const String baseUrl = 'https://tu-app-django.onrender.com/api/v1';
  static const String baseUrl = 'http://192.168.1.8:8000/api/v1';

  Future<Map<String, dynamic>> _postRequest(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error del servidor: ${response.statusCode} ${response.body}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Error de conexión: No se pudo conectar al servidor. Verifica tu internet y que el servidor esté activo. ($e)');
    } catch (e) {
      if (e.toString().contains('SocketException')) {
         throw Exception('Error de red: No se puede alcanzar el servidor ($baseUrl). \n\nAsegúrate de:\n1. Estar en la misma red WiFi.\n2. Que el servidor Django esté corriendo (0.0.0.0).\n3. Que el Firewall de Windows permita Python.');
      }
      throw Exception('Error inesperado: $e');
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final data = await _postRequest('/users/login/', {
      'username': username,
      'password': password,
    });
    return {
      'username': data['user']['username'],
      'email': data['user']['email'],
      'hearts': data['user']['profile']['hearts'],
      'gems': data['user']['profile']['gems'],
      'streak': data['user']['profile']['streak_days'],
      'token': data['token'],
    };
  }

  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    final data = await _postRequest('/users/register/', {
      'username': username,
      'email': email,
      'password': password,
    });
    return {
      'username': data['user']['username'],
      'email': data['user']['email'],
      'hearts': data['user']['profile']['hearts'],
      'gems': data['user']['profile']['gems'],
      'streak': data['user']['profile']['streak_days'],
      'token': data['token'],
    };
  }

  Future<Map<String, dynamic>> signInWithGoogle(String idToken) async {
    final data = await _postRequest('/users/google-login/', {
      'id_token': idToken,
    });
    return {
      'username': data['user']['username'],
      'email': data['user']['email'],
      'hearts': data['user']['profile']['hearts'],
      'gems': data['user']['profile']['gems'],
      'streak': data['user']['profile']['streak_days'],
      'token': data['token'],
    };
  }
}
