import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Cambia esto a tu URL de Render una vez desplegado:
  static const String baseUrl = 'https://biblialingo-app.onrender.com/api/v1';
  // Para desarrollo local, descomenta la siguiente línea y comenta la anterior:
  // static const String baseUrl = 'http://192.168.1.8:8000/api/v1';

  // Token de autenticación — se establece al hacer login/register
  String? _authToken;

  void setToken(String? token) {
    _authToken = token;
  }

  String? get token => _authToken;

  Map<String, String> _buildHeaders({bool withAuth = false}) {
    final headers = {'Content-Type': 'application/json'};
    if (withAuth && _authToken != null) {
      headers['Authorization'] = 'Token $_authToken';
    }
    return headers;
  }

  Future<Map<String, dynamic>> _postRequest(String endpoint, Map<String, dynamic> body, {bool withAuth = false}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _buildHeaders(withAuth: withAuth),
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

  Future<Map<String, dynamic>> _getRequest(String endpoint, {bool withAuth = false}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _buildHeaders(withAuth: withAuth),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException') || e.toString().contains('SocketException')) {
        throw Exception('No se puede conectar al servidor.');
      }
      throw Exception('Error inesperado: $e');
    }
  }

  // =========================================================================
  // AUTH
  // =========================================================================

  Future<Map<String, dynamic>> login(String username, String password) async {
    final data = await _postRequest('/users/login/', {
      'username': username,
      'password': password,
    });
    _authToken = data['token'];
    return {
      'username': data['user']['username'],
      'email': data['user']['email'],
      'hearts': data['user']['profile']['hearts'],
      'gems': data['user']['profile']['gems'],
      'streak': data['user']['profile']['streak_days'],
      'totalXp': data['user']['profile']['total_xp'],
      'lastHeartRegen': data['user']['profile']['last_heart_regen'],
      'token': data['token'],
    };
  }

  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    final data = await _postRequest('/users/register/', {
      'username': username,
      'email': email,
      'password': password,
    });
    _authToken = data['token'];
    return {
      'username': data['user']['username'],
      'email': data['user']['email'],
      'hearts': data['user']['profile']['hearts'],
      'gems': data['user']['profile']['gems'],
      'streak': data['user']['profile']['streak_days'],
      'totalXp': data['user']['profile']['total_xp'],
      'lastHeartRegen': data['user']['profile']['last_heart_regen'],
      'token': data['token'],
    };
  }

  Future<Map<String, dynamic>> signInWithGoogle(String idToken) async {
    final data = await _postRequest('/users/google-login/', {
      'id_token': idToken,
    });
    _authToken = data['token'];
    return {
      'username': data['user']['username'],
      'email': data['user']['email'],
      'hearts': data['user']['profile']['hearts'],
      'gems': data['user']['profile']['gems'],
      'streak': data['user']['profile']['streak_days'],
      'totalXp': data['user']['profile']['total_xp'],
      'lastHeartRegen': data['user']['profile']['last_heart_regen'],
      'token': data['token'],
    };
  }

  // =========================================================================
  // CURRICULUM
  // =========================================================================

  Future<Map<String, dynamic>> fetchCurriculum() async {
    try {
      return await _getRequest(
        '/curriculum/courses/1/dashboard_data/',
        withAuth: true,
      );
    } catch (e) {
      print('Error fetching curriculum: $e');
      // FALLBACK / OFFLINE MODE — para que la app funcione sin servidor
      return _offlineCurriculum();
    }
  }

  Future<Map<String, dynamic>> getLessonDetails(int lessonId) async {
    try {
      return await _getRequest(
        '/curriculum/lessons/$lessonId/',
        withAuth: true,
      );
    } catch (e) {
      print('Error fetching lesson details: $e');
      // Fallback minimalista
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

  // =========================================================================
  // EXERCISES
  // =========================================================================

  Future<Map<String, dynamic>> submitAnswer({
    required int exerciseId,
    required bool isCorrect,
    int timeSpentSeconds = 0,
  }) async {
    return await _postRequest('/exercises/submit/', {
      'exercise_id': exerciseId,
      'is_correct': isCorrect,
      'time_spent_seconds': timeSpentSeconds,
    }, withAuth: true);
  }

  // =========================================================================
  // PROFILE & SHOP
  // =========================================================================

  Future<Map<String, dynamic>> getProfile() async {
    return await _getRequest('/users/profile/', withAuth: true);
  }

  Future<Map<String, dynamic>> patchProfile(Map<String, dynamic> data) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/users/profile/'),
        headers: _buildHeaders(withAuth: true),
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al actualizar perfil: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('No se pudo actualizar el perfil: $e');
    }
  }

  Future<Map<String, dynamic>> shopPurchase(String itemType) async {
    return await _postRequest('/users/shop/purchase/', {
      'item_type': itemType,
    }, withAuth: true);
  }

  // =========================================================================
  // OFFLINE FALLBACK
  // =========================================================================

  Map<String, dynamic> _offlineCurriculum() {
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
        // UNIDAD 3-6 abreviadas
        for (int i = 11; i <= 50; i++)
          { 'id': i, 'title': 'Génesis $i', 'order': i, 'is_unlocked': false, 'progress': 0.0 },
      ]
    };
  }
}
