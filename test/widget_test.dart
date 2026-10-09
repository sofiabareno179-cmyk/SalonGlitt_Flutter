import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mi_app/main.dart';
import 'package:mi_app/services/salon_glitt_service.dart';

class _FakeSalonGlittService extends SalonGlittService {
  Map<String, dynamic>? registeredUser;

  @override
  Future<Map<String, dynamic>> checkHealth() async => {
    'status': 'ok',
    'service': 'SGE-API',
    'version': '1.0.0',
  };

  @override
  Future<Map<String, dynamic>> register({
    required String nombreuser,
    required String email,
    required String password,
    String? telefono,
  }) async {
    registeredUser = {
      'nombreuser': nombreuser,
      'email': email,
      'password': password,
    };
    return {
      'id': 1,
      'nombreuser': nombreuser,
      'email': email,
      'telefono': telefono,
      'rol': 'cliente',
    };
  }
}

void main() {
  group('SalonGlittService', () {
    const baseUrl = 'https://api.example.test';
    late Future<http.Response> Function(http.Request request) responseHandler;
    late MockClient client;
    late SalonGlittService service;

    setUp(() {
      responseHandler = (_) async => http.Response('{}', 200);
      client = MockClient((request) => responseHandler(request));
      service = SalonGlittService(baseUrl: baseUrl, client: client);
    });

    tearDown(() {
      client.close();
    });

    test('starts logged out and logout clears session data', () async {
      expect(service.token, isNull);
      expect(service.currentUser, isNull);
      expect(service.isAuthenticated, isFalse);

      responseHandler = (_) async =>
          http.Response(jsonEncode({'access_token': 'token-123'}), 200);
      await service.login(email: 'ana@example.test', password: 'secret');
      responseHandler = (_) async =>
          http.Response(jsonEncode({'id': 7, 'nombreuser': 'Ana'}), 200);
      await service.getProfile();

      expect(service.isAuthenticated, isTrue);
      expect(service.currentUser, {'id': 7, 'nombreuser': 'Ana'});

      service.logout();

      expect(service.token, isNull);
      expect(service.currentUser, isNull);
      expect(service.isAuthenticated, isFalse);
    });

    test('checkHealth requests health endpoint and decodes response', () async {
      responseHandler = (request) async {
        expect(request.method, 'GET');
        expect(request.url, Uri.parse('$baseUrl/health'));
        return http.Response(
          jsonEncode({'status': 'ok', 'version': '1.0.0'}),
          200,
        );
      };

      expect(await service.checkHealth(), {'status': 'ok', 'version': '1.0.0'});
    });

    test('checkHealth reports non-success and connection errors', () async {
      responseHandler = (_) async => http.Response('unavailable', 503);
      await expectLater(
        service.checkHealth(),
        throwsA(
          isA<Exception>()
              .having((error) => error.toString(), 'message', contains('503'))
              .having(
                (error) => error.toString(),
                'message',
                contains('Fallo al conectar con la API desplegada'),
              ),
        ),
      );

      responseHandler = (_) async => throw StateError('offline');
      await expectLater(
        service.checkHealth(),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('offline'),
          ),
        ),
      );
    });

    test('login sends credentials, returns data, and stores token', () async {
      responseHandler = (request) async {
        expect(request.method, 'POST');
        expect(request.url, Uri.parse('$baseUrl/api/v1/auth/login'));
        expect(request.headers['content-type'], 'application/json');
        expect(jsonDecode(request.body), {
          'email': 'ana@example.test',
          'password': 'secret',
        });
        return http.Response(
          jsonEncode({'access_token': 'token-123', 'token_type': 'bearer'}),
          200,
        );
      };

      expect(
        await service.login(email: 'ana@example.test', password: 'secret'),
        {'access_token': 'token-123', 'token_type': 'bearer'},
      );
      expect(service.token, 'token-123');
      expect(service.isAuthenticated, isTrue);
    });

    test(
      'login stringifies token and rejects missing token or failed status',
      () async {
        responseHandler = (_) async =>
            http.Response(jsonEncode({'access_token': 42}), 201);
        await service.login(email: 'ana@example.test', password: 'secret');
        expect(service.token, '42');

        responseHandler = (_) async =>
            http.Response(jsonEncode({'token': 'missing'}), 200);
        await expectLater(
          service.login(email: 'ana@example.test', password: 'secret'),
          throwsA(
            isA<Exception>().having(
              (error) => error.toString(),
              'message',
              allOf(
                contains('access_token'),
                contains('Error en inicio de sesión'),
              ),
            ),
          ),
        );

        responseHandler = (_) async =>
            http.Response('invalid credentials', 401);
        await expectLater(
          service.login(email: 'ana@example.test', password: 'secret'),
          throwsA(
            isA<Exception>().having(
              (error) => error.toString(),
              'message',
              allOf(contains('401'), contains('Error en inicio de sesión')),
            ),
          ),
        );
      },
    );

    test('register sends fields and omits an empty optional phone', () async {
      responseHandler = (request) async {
        expect(request.method, 'POST');
        expect(request.url, Uri.parse('$baseUrl/api/v1/auth/register'));
        expect(request.headers['content-type'], 'application/json');
        expect(jsonDecode(request.body), {
          'nombreuser': 'Ana Cliente',
          'email': 'ana@example.test',
          'password': 'secret',
        });
        return http.Response(jsonEncode({'id': 7}), 201);
      };

      expect(
        await service.register(
          nombreuser: 'Ana Cliente',
          email: 'ana@example.test',
          password: 'secret',
          telefono: '',
        ),
        {'id': 7},
      );
    });

    test(
      'register includes a provided phone and reports failed status',
      () async {
        responseHandler = (request) async {
          expect(jsonDecode(request.body), {
            'nombreuser': 'Ana Cliente',
            'email': 'ana@example.test',
            'password': 'secret',
            'telefono': '5551234',
          });
          return http.Response(jsonEncode({'id': 7}), 200);
        };
        expect(
          await service.register(
            nombreuser: 'Ana Cliente',
            email: 'ana@example.test',
            password: 'secret',
            telefono: '5551234',
          ),
          {'id': 7},
        );

        responseHandler = (_) async => http.Response('email taken', 409);
        await expectLater(
          service.register(
            nombreuser: 'Ana Cliente',
            email: 'ana@example.test',
            password: 'secret',
          ),
          throwsA(
            isA<Exception>().having(
              (error) => error.toString(),
              'message',
              allOf(contains('409'), contains('Fallo al registrar usuario')),
            ),
          ),
        );
      },
    );

    test('getProfile requires login and saves the fetched user', () async {
      await expectLater(
        service.getProfile(),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('No has iniciado sesión'),
          ),
        ),
      );

      responseHandler = (_) async =>
          http.Response(jsonEncode({'access_token': 'token'}), 200);
      expect(
        await service.login(email: 'ana@example.test', password: 'secret'),
        {'access_token': 'token'},
      );
      responseHandler = (request) async {
        expect(request.method, 'GET');
        expect(request.url, Uri.parse('$baseUrl/api/v1/auth/me'));
        expect(request.headers['authorization'], isNotNull);
        return http.Response(jsonEncode({'id': 7, 'nombreuser': 'Ana'}), 200);
      };
      expect(await service.getProfile(), {'id': 7, 'nombreuser': 'Ana'});
      expect(service.currentUser, {'id': 7, 'nombreuser': 'Ana'});
    });

    test('getProfile reports a failed response', () async {
      responseHandler = (_) async =>
          http.Response(jsonEncode({'access_token': 'token'}), 200);
      await service.login(email: 'ana@example.test', password: 'secret');
      responseHandler = (_) async => http.Response('expired', 401);

      await expectLater(
        service.getProfile(),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            allOf(contains('401'), contains('Error al obtener perfil')),
          ),
        ),
      );
    });

    test(
      'getAuthenticated requires login and decodes any JSON response',
      () async {
        await expectLater(
          service.getAuthenticated('/api/v1/servicios'),
          throwsA(
            isA<Exception>().having(
              (error) => error.toString(),
              'message',
              contains('No hay token JWT de sesión'),
            ),
          ),
        );

        responseHandler = (_) async =>
            http.Response(jsonEncode({'access_token': 'token'}), 200);
        await service.login(email: 'ana@example.test', password: 'secret');
        responseHandler = (request) async {
          expect(request.method, 'GET');
          expect(request.url, Uri.parse('$baseUrl/api/v1/servicios'));
          return http.Response(
            jsonEncode([
              {'id': 1, 'nombre': 'Corte'},
            ]),
            200,
          );
        };

        expect(await service.getAuthenticated('/api/v1/servicios'), [
          {'id': 1, 'nombre': 'Corte'},
        ]);
      },
    );

    test('getAuthenticated reports a failed response', () async {
      responseHandler = (_) async =>
          http.Response(jsonEncode({'access_token': 'token'}), 200);
      await service.login(email: 'ana@example.test', password: 'secret');
      responseHandler = (_) async => http.Response('forbidden', 403);

      await expectLater(
        service.getAuthenticated('/api/v1/servicios'),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            allOf(contains('403'), contains('Error [403]')),
          ),
        ),
      );
    });
  });

  testWidgets('el formulario envía los campos compatibles con FastAPI', (
    tester,
  ) async {
    final service = _FakeSalonGlittService();
    await tester.pumpWidget(
      MaterialApp(home: SalonGlittHomePage(apiService: service)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bienvenida de vuelta'), findsOneWidget);
    await tester.ensureVisible(find.text('¿Primera vez aquí? Crea tu cuenta'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('¿Primera vez aquí? Crea tu cuenta'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('nombreuser-field')),
      'Ana Cliente',
    );
    await tester.enterText(
      find.byKey(const Key('email-field')),
      'ana@example.test',
    );
    await tester.enterText(
      find.byKey(const Key('password-field')),
      'Contrasena1',
    );
    await tester.ensureVisible(find.text('Crear mi cuenta'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Crear mi cuenta'));
    await tester.pumpAndSettle();

    expect(service.registeredUser, {
      'nombreuser': 'Ana Cliente',
      'email': 'ana@example.test',
      'password': 'Contrasena1',
    });
    expect(find.text('Bienvenida de vuelta'), findsOneWidget);
  });
}
