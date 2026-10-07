import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
