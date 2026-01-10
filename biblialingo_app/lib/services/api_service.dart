import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Cambia esto a tu URL de Render una vez desplegado:
  static const String baseUrl = 'https://biblialingo-app.onrender.com/api/v1';
  // static const String baseUrl = 'http://192.168.1.8:8000/api/v1';

  Future<Map<String, dynamic>> _postRequest(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error del servidor: ${response.statusCode} ${response.body}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Error de conexión: No se pudo conectar al servidor. Verifica que tu PC y móvil estén en la misma WiFi y que el Firewall de Windows permita conexiones a Python. ($e)');
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
           throw Exception('Tiempo de espera agotado (30s). Probablemente el Firewall de Windows está bloqueando la conexión. \n\nSolución:\n1. Abre "Permitir una aplicación a través del Firewall" en Windows.\n2. Busca "python.exe" y marca "Privada" y "Pública".');
      }
      if (e.toString().contains('SocketException')) {
         throw Exception('Error de red: No se puede alcanzar el servidor ($baseUrl). \n\nAsegúrate de:\n1. Estar en la misma red WiFi.\n2. Que el servidor Django esté corriendo (0.0.0.0).\n3. Desactivar temporalmente el Firewall.');
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

  Future<Map<String, dynamic>> fetchCurriculum() async {
    // Hardcoded course ID 1 for Genesis
    // We use GET for this one, so we need a _getRequest helper or just inline it
    try {
      final token = 'YOUR_TOKEN'; // TODO: Get from persistence
      
      // Implement GET request logic here briefly since _postRequest is specific
      final response = await http.get(
        Uri.parse('$baseUrl/curriculum/courses/1/dashboard_data/'),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Token $token', // Uncomment when auth is fully wired
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching curriculum: $e');
      // FALLBACK / OFFLINE MODE
      // If server is down or empty, return this dummy data so the app works:
      return {
        'course_title': 'Génesis RVR1960 (Offline)',
        'lessons': [
          // UNIDAD 1: Los Orígenes
          { 'id': 1, 'title': 'Génesis 1: La Creación', 'order': 1, 'is_unlocked': true, 'progress': 0.7 },
          { 'id': 2, 'title': 'Génesis 2: El Edén', 'order': 2, 'is_unlocked': true, 'progress': 0.3 },
          { 'id': 3, 'title': 'Génesis 3: La Caída', 'order': 3, 'is_unlocked': true, 'progress': 0.0 },
          { 'id': 4, 'title': 'Génesis 4: Caín y Abel', 'order': 4, 'is_unlocked': false, 'progress': 0.0 },
          { 'id': 5, 'title': 'Génesis 5: Genealogía', 'order': 5, 'is_unlocked': false, 'progress': 0.0 },
          
          // UNIDAD 2: El Diluvio
          { 'id': 6, 'title': 'Génesis 6: Maldad', 'order': 6, 'is_unlocked': false, 'progress': 0.0 },
          { 'id': 7, 'title': 'Génesis 7: El Diluvio', 'order': 7, 'is_unlocked': false, 'progress': 0.0 },
          { 'id': 8, 'title': 'Génesis 8: El Final', 'order': 8, 'is_unlocked': false, 'progress': 0.0 },
          { 'id': 9, 'title': 'Génesis 9: Pacto', 'order': 9, 'is_unlocked': false, 'progress': 0.0 },
          { 'id': 10, 'title': 'Génesis 10: Naciones', 'order': 10, 'is_unlocked': false, 'progress': 0.0 },

          // UNIDAD 3: Babel y Abraham
          { 'id': 11, 'title': 'Génesis 11: Babel', 'order': 11, 'is_unlocked': false, 'progress': 0.0 },
          { 'id': 12, 'title': 'Génesis 12: Abram', 'order': 12, 'is_unlocked': false, 'progress': 0.0 },
          { 'id': 13, 'title': 'Génesis 13: Lot', 'order': 13, 'is_unlocked': false, 'progress': 0.0 },
          { 'id': 14, 'title': 'Génesis 14: Melquisedec', 'order': 14, 'is_unlocked': false, 'progress': 0.0 },
          { 'id': 15, 'title': 'Génesis 15: Pacto', 'order': 15, 'is_unlocked': false, 'progress': 0.0 },
          { 'id': 16, 'title': 'Génesis 16: Agar', 'order': 16, 'is_unlocked': false, 'progress': 0.0 },
          { 'id': 17, 'title': 'Génesis 17: Circuncisión', 'order': 17, 'is_unlocked': false, 'progress': 0.0 },
          { 'id': 18, 'title': 'Génesis 18: Promesa', 'order': 18, 'is_unlocked': false, 'progress': 0.0 },
          { 'id': 19, 'title': 'Génesis 19: Sodoma', 'order': 19, 'is_unlocked': false, 'progress': 0.0 },
          { 'id': 20, 'title': 'Génesis 20: Abimelec', 'order': 20, 'is_unlocked': false, 'progress': 0.0 },

          // UNIDAD 4: Isaac y Jacob
          { 'id': 21, 'title': 'Génesis 21: Isaac', 'order': 21, 'is_unlocked': false, 'progress': 0.0 },
          { 'id': 22, 'title': 'Génesis 22: Sacrificio', 'order': 22, 'is_unlocked': false, 'progress': 0.0 },
          { 'id': 23, 'title': 'Génesis 23: Sepultura', 'order': 23, 'is_unlocked': false, 'progress': 0.0 },
          { 'id': 24, 'title': 'Génesis 24: Rebeca', 'order': 24, 'is_unlocked': false, 'progress': 0.0 },
          { 'id': 25, 'title': 'Génesis 25: Jacob y Esaú', 'order': 25, 'is_unlocked': false, 'progress': 0.0 },
          { 'id': 26, 'title': 'Génesis 26: Isaac', 'order': 26, 'is_unlocked': false, 'progress': 0.0 },
          { 'id': 27, 'title': 'Génesis 27: Bendición', 'order': 27, 'is_unlocked': false, 'progress': 0.0 },
          { 'id': 28, 'title': 'Génesis 28: Escalera', 'order': 28, 'is_unlocked': false, 'progress': 0.0 },
          { 'id': 29, 'title': 'Génesis 29: Lea y Raquel', 'order': 29, 'is_unlocked': false, 'progress': 0.0 },
          { 'id': 30, 'title': 'Génesis 30: Hijos', 'order': 30, 'is_unlocked': false, 'progress': 0.0 },
          
          // UNIDAD 5: Jacob regresa
          { 'id': 31, 'title': 'Génesis 31: Huida', 'order': 31, 'is_unlocked': false, 'progress': 0.0 },
          { 'id': 32, 'title': 'Génesis 32: Peniel', 'order': 32, 'is_unlocked': false, 'progress': 0.0 },
          { 'id': 33, 'title': 'Génesis 33: Encuentro', 'order': 33, 'is_unlocked': false, 'progress': 0.0 },
          { 'id': 34, 'title': 'Génesis 34: Dina', 'order': 34, 'is_unlocked': false, 'progress': 0.0 },
          { 'id': 35, 'title': 'Génesis 35: Bet-el', 'order': 35, 'is_unlocked': false, 'progress': 0.0 },
          { 'id': 36, 'title': 'Génesis 36: Edom', 'order': 36, 'is_unlocked': false, 'progress': 0.0 },

          // UNIDAD 6: La Historia de José
          { 'id': 37, 'title': 'Génesis 37: José vendido', 'order': 37, 'is_unlocked': false, 'progress': 0.0 },
          { 'id': 38, 'title': 'Génesis 38: Judá y Tamar', 'order': 38, 'is_unlocked': false, 'progress': 0.0 },
          { 'id': 39, 'title': 'Génesis 39: Potifar', 'order': 39, 'is_unlocked': false, 'progress': 0.0 },
          { 'id': 40, 'title': 'Génesis 40: El Copero', 'order': 40, 'is_unlocked': false, 'progress': 0.0 },
          { 'id': 41, 'title': 'Génesis 41: Faraón', 'order': 41, 'is_unlocked': false, 'progress': 0.0 },
          { 'id': 42, 'title': 'Génesis 42: Hermanos', 'order': 42, 'is_unlocked': false, 'progress': 0.0 },
          { 'id': 43, 'title': 'Génesis 43: Regreso', 'order': 43, 'is_unlocked': false, 'progress': 0.0 },
          { 'id': 44, 'title': 'Génesis 44: Copa', 'order': 44, 'is_unlocked': false, 'progress': 0.0 },
          { 'id': 45, 'title': 'Génesis 45: Revelación', 'order': 45, 'is_unlocked': false, 'progress': 0.0 },
          { 'id': 46, 'title': 'Génesis 46: Jacob en Egipto', 'order': 46, 'is_unlocked': false, 'progress': 0.0 },
          { 'id': 47, 'title': 'Génesis 47: Goshen', 'order': 47, 'is_unlocked': false, 'progress': 0.0 },
          { 'id': 48, 'title': 'Génesis 48: Bendición', 'order': 48, 'is_unlocked': false, 'progress': 0.0 },
          { 'id': 49, 'title': 'Génesis 49: 12 Tribus', 'order': 49, 'is_unlocked': false, 'progress': 0.0 },
          { 'id': 50, 'title': 'Génesis 50: Muerte de José', 'order': 50, 'is_unlocked': false, 'progress': 0.0 },
        ]
      };
    }
  }

  Future<Map<String, dynamic>> getLessonDetails(int lessonId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/curriculum/lessons/$lessonId/'),
         headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error fetching lesson: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching lesson details: $e');
      // FALLBACK FOR DEMO (If server is down)
      return {
        'id': lessonId,
        'title': 'Lección $lessonId',
        'verses': [
           {
             'text': 'En el principio creó Dios los cielos y la tierra.',
             'exercises': [
                {
                   'exercise_type': 'cloze',
                   'question_data': {'text': 'En el principio creó Dios los _____ y la tierra.'},
                   'answer_data': {'correct': 'cielos'}
                }
             ]
           }
        ]
      };
    }
  }
}
