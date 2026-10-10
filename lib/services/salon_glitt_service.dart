import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../config/api_config.dart';

class SalonGlittService {
  final String baseUrl;
  String? _token;
  Map<String, dynamic>? _currentUser;

  SalonGlittService({this.baseUrl = ApiConfig.baseUrl});

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
      final response = await http.get(url).timeout(const Duration(seconds: 8));
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
      final response = await http
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
      final response = await http
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
    final response = await http
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
    final response = await http
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

  /// Sube la foto de perfil del usuario autenticado (POST /api/v1/auth/me/foto)
  Future<void> uploadProfilePhoto(
    Uint8List bytes, {
    required String fileName,
    String? mimeType,
  }) async {
    if (_token == null) {
      throw Exception('No has iniciado sesión.');
    }

    final uri = Uri.parse('$baseUrl${ApiConfig.profileFoto}');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $_token'
      ..files.add(
        http.MultipartFile.fromBytes(
          'foto',
          bytes,
          filename: fileName,
          contentType: MediaType('image', _mimeSubtype(fileName, mimeType)),
        ),
      );

    final streamed = await request.send().timeout(const Duration(seconds: 20));
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = response.body.trim();
      if (body.isNotEmpty) {
        try {
          final decoded = jsonDecode(body);
          if (decoded is Map<String, dynamic>) {
            _currentUser = {...?_currentUser, ...decoded};
          }
        } catch (_) {
          // La API puede responder vacía o sin JSON.
        }
      }
    } else {
      throw Exception(
        'Error al subir foto [${response.statusCode}]: ${response.body}',
      );
    }
  }

  String _mimeSubtype(String fileName, String? mimeType) {
    if (mimeType != null && mimeType.isNotEmpty) {
      final parts = mimeType.split('/');
      if (parts.length == 2) return parts.last.toLowerCase();
    }
    final extension = fileName.split('.').last.toLowerCase();
    const known = <String, String>{
      'jpg': 'jpeg',
      'jpeg': 'jpeg',
      'png': 'png',
      'gif': 'gif',
      'webp': 'webp',
      'bmp': 'bmp',
      'svg': 'svg+xml',
    };
    return known[extension] ?? 'png';
  }
}
