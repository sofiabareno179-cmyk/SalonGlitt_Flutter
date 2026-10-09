import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class SalonGlittService {
  final String baseUrl;
  final http.Client _client;
  String? _token;
  Map<String, dynamic>? _currentUser;

  SalonGlittService({this.baseUrl = ApiConfig.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  String? get token => _token;
  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  void logout() {
    _token = null;
    _currentUser = null;
  }

  /// Comprueba el estado del servidor (/health)
  Future<Map<String, dynamic>> checkHealth() async {
    final url = Uri.parse('$baseUrl${ApiConfig.healthCheck}');
    try {
      final response = await _client
          .get(url)
          .timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
          'Servidor respondió con [${response.statusCode}]: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Fallo al conectar con la API desplegada: $e');
    }
  }

  /// Inicia sesión (POST /api/v1/auth/login)
  /// Recibe {"email": "...", "password": "..."}
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl${ApiConfig.login}');

    try {
      final response = await _client
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data.containsKey('access_token')) {
          _token = data['access_token'].toString();
        } else {
          throw Exception('La API no devolvió el campo access_token.');
        }
        return data;
      } else {
        throw Exception('Error [${response.statusCode}]: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error en inicio de sesión: $e');
    }
  }

  /// Registro de nuevo usuario (POST /api/v1/auth/register)
  Future<Map<String, dynamic>> register({
    required String nombreuser,
    required String email,
    required String password,
    String? telefono,
  }) async {
    final url = Uri.parse('$baseUrl${ApiConfig.register}');

    try {
      final response = await _client
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'nombreuser': nombreuser,
              'email': email,
              'password': password,
              if (telefono != null && telefono.isNotEmpty) 'telefono': telefono,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
          'Error en registro [${response.statusCode}]: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Fallo al registrar usuario: $e');
    }
  }

  /// Obtiene los datos del usuario autenticado actual (GET /api/v1/auth/me)
  Future<Map<String, dynamic>> getProfile() async {
    if (_token == null) {
      throw Exception('No has iniciado sesión.');
    }

    final url = Uri.parse('$baseUrl${ApiConfig.profile}');
    final response = await _client
        .get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_token',
          },
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final user = jsonDecode(response.body) as Map<String, dynamic>;
      _currentUser = user;
      return user;
    } else {
      throw Exception(
        'Error al obtener perfil [${response.statusCode}]: ${response.body}',
      );
    }
  }

  /// Petición autenticada genérica
  Future<dynamic> getAuthenticated(String endpoint) async {
    if (_token == null) {
      throw Exception('No hay token JWT de sesión.');
    }

    final url = Uri.parse('$baseUrl$endpoint');
    final response = await _client
        .get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_token',
          },
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error [${response.statusCode}]: ${response.body}');
    }
  }
}
