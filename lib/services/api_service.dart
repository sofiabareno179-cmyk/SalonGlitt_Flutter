import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Para Windows de escritorio o Web usamos http://127.0.0.1:8000
  // Si en el futuro usas emulador Android cambia a: 'http://10.0.2.2:8000'
  final String baseUrl;

  ApiService({this.baseUrl = 'http://127.0.0.1:8000'});

  /// Ejemplo: Probar conexión con FastAPI (GET /)
  Future<Map<String, dynamic>> checkHealth() async {
    final url = Uri.parse('$baseUrl/');
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
          'Error del servidor: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('No se pudo conectar con FastAPI: $e');
    }
  }

  /// Ejemplo GET genérico
  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error [${response.statusCode}]: ${response.body}');
      }
    } catch (e) {
      throw Exception('Fallo en la petición GET $endpoint: $e');
    }
  }

  /// Ejemplo POST genérico
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error [${response.statusCode}]: ${response.body}');
      }
    } catch (e) {
      throw Exception('Fallo en la petición POST $endpoint: $e');
    }
  }
}
