class ApiConfig {
  // URL base de tu API desplegada (SGE-API / SalonGlitt)
  static const String baseUrl = 'http://vqtkftbflcvjex3dh3gjyxx1.89.117.53.189.sslip.io';

  // Endpoints exactos de la API
  static const String healthCheck = '/health';
  static const String login = '/api/v1/auth/login';
  static const String register = '/api/v1/auth/register';
  static const String profile = '/api/v1/auth/me';

  // Otros módulos disponibles en SalonGlitt
  static const String servicios = '/api/v1/servicios';
  static const String citas = '/api/v1/citas';
  static const String agenda = '/api/v1/agenda';
  static const String productos = '/api/v1/productos';
  static const String catalogoPrecios = '/api/v1/catalogo-precios';
}
