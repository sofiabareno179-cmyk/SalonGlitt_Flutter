import 'package:flutter/material.dart';

import 'config/api_config.dart';
import 'services/salon_glitt_service.dart';

void main() {
  runApp(const SalonGlittApp());
}

class SalonGlittColors {
  // Paleta Morado, Rosa y Dorado
  static const Color deepPurple = Color(0xFF2E0854); // Morado profundo elegante
  static const Color royalPurple = Color(0xFF5B1889); // Morado intermedio
  static const Color brightPurple = Color(0xFF7B1FA2); // Morado vivo
  static const Color hotPink = Color(0xFFE91E63); // Rosa vibrante
  static const Color softPink = Color(0xFFFCE4EC); // Rosa pastel suave
  static const Color lightBlush = Color(0xFFFAF5FA); // Fondo suave
  static const Color metallicGold = Color(
    0xFFD4AF37,
  ); // Dorado clásico metálico
  static const Color lightGold = Color(0xFFFFE082); // Dorado brillante claro
  static const Color darkGold = Color(0xFFA67C1E); // Dorado oscuro para bordes
  static const Color terminalBg = Color(
    0xFF180326,
  ); // Morado oscuro para consola
}

class SalonGlittApp extends StatelessWidget {
  const SalonGlittApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SalonGlitt App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: SalonGlittColors.lightBlush,
        colorScheme: ColorScheme.fromSeed(
          seedColor: SalonGlittColors.royalPurple,
          primary: SalonGlittColors.royalPurple,
          secondary: SalonGlittColors.hotPink,
          tertiary: SalonGlittColors.metallicGold,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const SalonGlittHomePage(),
    );
  }
}

class SalonGlittHomePage extends StatefulWidget {
  const SalonGlittHomePage({super.key});

  @override
  State<SalonGlittHomePage> createState() => _SalonGlittHomePageState();
}

class _SalonGlittHomePageState extends State<SalonGlittHomePage> {
  final SalonGlittService _apiService = SalonGlittService();

  // Controladores de texto para Login
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Controladores para Registro
  final TextEditingController _regNombreController = TextEditingController();
  final TextEditingController _regApellidoController = TextEditingController();
  final TextEditingController _regEmailController = TextEditingController();
  final TextEditingController _regPasswordController = TextEditingController();
  final TextEditingController _regTelefonoController = TextEditingController();

  bool _isRegisterMode = false;
  bool _isLoading = false;
  String _statusMessage = 'Conectando a SGE-API desplegada...';
  bool _isOnline = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    // Comprobamos automáticamente el estado de la API al iniciar
    _checkServerHealth();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _regNombreController.dispose();
    _regApellidoController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    _regTelefonoController.dispose();
    super.dispose();
  }

  // 1. Probar conexión a /health
  Future<void> _checkServerHealth() async {
    setState(() {
      _isLoading = true;
      _statusMessage =
          'Comprobando conexión con ${ApiConfig.baseUrl}/health...';
    });

    try {
      final res = await _apiService.checkHealth();
      setState(() {
        _isOnline = true;
        _statusMessage = '¡API Conectada y Operativa!\nRespuesta: $res';
      });
    } catch (e) {
      setState(() {
        _isOnline = false;
        _statusMessage = 'Error al conectar con la API:\n$e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 2. Iniciar sesión con JWT (/api/v1/auth/login)
  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: SalonGlittColors.hotPink,
          content: Text('Por favor completa correo electrónico y contraseña'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Iniciando sesión en ${ApiConfig.login}...';
    });

    try {
      final response = await _apiService.login(
        email: email,
        password: password,
      );
      // Tras el login exitoso, cargamos el perfil del usuario
      final profile = await _apiService.getProfile();

      setState(() {
        _isOnline = true;
        _statusMessage =
            '¡Bienvenido, ${profile['nombre']} ${profile['apellido']}!\n\nToken JWT:\n${_apiService.token}';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: SalonGlittColors.royalPurple,
            content: Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: SalonGlittColors.metallicGold,
                ),
                const SizedBox(width: 8),
                Text('¡Bienvenido a SalonGlitt, ${profile['nombre']}!'),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error en el inicio de sesión:\n$e';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: SalonGlittColors.hotPink,
            content: Text('Error: $e'),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 3. Registrar nuevo usuario (/api/v1/auth/register)
  Future<void> _handleRegister() async {
    final nombre = _regNombreController.text.trim();
    final apellido = _regApellidoController.text.trim();
    final email = _regEmailController.text.trim();
    final password = _regPasswordController.text.trim();
    final telefono = _regTelefonoController.text.trim();

    if (nombre.isEmpty ||
        apellido.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: SalonGlittColors.hotPink,
          content: Text('Completa todos los campos obligatorios'),
        ),
      );
      return;
    }

    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: SalonGlittColors.hotPink,
          content: Text('La contraseña debe tener al menos 8 caracteres'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Registrando usuario en ${ApiConfig.register}...';
    });

    try {
      final result = await _apiService.register(
        nombre: nombre,
        apellido: apellido,
        email: email,
        password: password,
        telefono: telefono.isNotEmpty ? telefono : null,
      );

      setState(() {
        _statusMessage = '¡Usuario registrado con éxito!\n$result';
        _isRegisterMode = false;
        _emailController.text = email;
        _passwordController.text = password;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('¡Cuenta creada! Ya puedes iniciar sesión.'),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error al registrar:\n$e';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: SalonGlittColors.hotPink,
            content: Text('Error: $e'),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 4. Consultar Servicios (/api/v1/servicios)
  Future<void> _fetchServicios() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Consultando catálogo de servicios...';
    });

    try {
      final data = await _apiService.getAuthenticated(ApiConfig.servicios);
      setState(() {
        _statusMessage = 'Servicios disponibles de SalonGlitt:\n$data';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error al consultar servicios:\n$e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleLogout() {
    setState(() {
      _apiService.logout();
      _statusMessage = 'Sesión cerrada.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                SalonGlittColors.deepPurple,
                SalonGlittColors.royalPurple,
                SalonGlittColors.hotPink,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: SalonGlittColors.metallicGold,
                        width: 2,
                      ),
                      color: Colors.white.withOpacity(0.15),
                    ),
                    child: const Icon(
                      Icons.spa,
                      color: SalonGlittColors.lightGold,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'SalonGlitt API',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'SGE-API Desplegada • Online',
                        style: TextStyle(
                          fontSize: 11,
                          color: SalonGlittColors.lightGold,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.auto_awesome,
                    color: SalonGlittColors.metallicGold,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner de Estado del Servidor
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [Colors.white, Color(0xFFFFF9FC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: SalonGlittColors.metallicGold.withOpacity(0.6),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: SalonGlittColors.royalPurple.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isOnline
                          ? Colors.green.withOpacity(0.15)
                          : SalonGlittColors.softPink,
                      border: Border.all(
                        color: _isOnline
                            ? Colors.green
                            : SalonGlittColors.hotPink,
                        width: 1.8,
                      ),
                    ),
                    child: Icon(
                      _isOnline ? Icons.check_circle : Icons.cloud_outlined,
                      color: _isOnline
                          ? Colors.green
                          : SalonGlittColors.hotPink,
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isOnline ? 'Conectado a SGE-API' : 'Desconectado',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: _isOnline
                                ? Colors.green[800]
                                : SalonGlittColors.deepPurple,
                          ),
                        ),
                        const Text(
                          ApiConfig.baseUrl,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _checkServerHealth,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SalonGlittColors.royalPurple,
                      foregroundColor: SalonGlittColors.lightGold,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                          color: SalonGlittColors.metallicGold,
                          width: 1,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.sync, size: 16),
                    label: const Text('Comprobar'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tarjeta de Autenticación (Login / Registro)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: Colors.white,
                border: Border.all(
                  color: SalonGlittColors.metallicGold.withOpacity(0.4),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: SalonGlittColors.hotPink.withOpacity(0.07),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(22.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabecera
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isRegisterMode
                                ? Icons.person_add
                                : Icons.lock_person,
                            color: SalonGlittColors.royalPurple,
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _isRegisterMode ? 'Crear Cuenta' : 'Iniciar Sesión',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: SalonGlittColors.deepPurple,
                            ),
                          ),
                        ],
                      ),
                      if (_apiService.isAuthenticated)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: SalonGlittColors.softPink,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: SalonGlittColors.metallicGold,
                              width: 1.2,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified,
                                color: SalonGlittColors.hotPink,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Sesión Activa',
                                style: TextStyle(
                                  color: SalonGlittColors.royalPurple,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (!_apiService.isAuthenticated) ...[
                    // Formulario de Registro o Login
                    if (_isRegisterMode) ...[
                      // CAMPOS REGISTRO
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _regNombreController,
                              decoration: const InputDecoration(
                                labelText: 'Nombre',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _regApellidoController,
                              decoration: const InputDecoration(
                                labelText: 'Apellido',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _regEmailController,
                        decoration: const InputDecoration(
                          labelText: 'Correo Electrónico',
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: SalonGlittColors.hotPink,
                          ),
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _regTelefonoController,
                        decoration: const InputDecoration(
                          labelText: 'Teléfono (Opcional)',
                          prefixIcon: Icon(
                            Icons.phone_outlined,
                            color: SalonGlittColors.hotPink,
                          ),
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _regPasswordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Contraseña (mínimo 8 caracteres)',
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: SalonGlittColors.hotPink,
                          ),
                          border: const OutlineInputBorder(),
                          isDense: true,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: SalonGlittColors.metallicGold,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Botón Registrarse
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: const LinearGradient(
                            colors: [
                              SalonGlittColors.royalPurple,
                              SalonGlittColors.hotPink,
                            ],
                          ),
                          border: Border.all(
                            color: SalonGlittColors.metallicGold,
                            width: 1.4,
                          ),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          icon: const Icon(
                            Icons.person_add,
                            color: SalonGlittColors.lightGold,
                          ),
                          label: Text(
                            _isLoading
                                ? 'Registrando...'
                                : 'Registrarme en SalonGlitt',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      // CAMPOS LOGIN
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Correo Electrónico (Email)',
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: SalonGlittColors.hotPink,
                          ),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: SalonGlittColors.hotPink,
                          ),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: SalonGlittColors.metallicGold,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Botón Iniciar Sesión
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: const LinearGradient(
                            colors: [
                              SalonGlittColors.royalPurple,
                              SalonGlittColors.hotPink,
                            ],
                          ),
                          border: Border.all(
                            color: SalonGlittColors.metallicGold,
                            width: 1.4,
                          ),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: SalonGlittColors.lightGold,
                                  ),
                                )
                              : const Icon(
                                  Icons.login,
                                  color: SalonGlittColors.lightGold,
                                ),
                          label: Text(
                            _isLoading ? 'Conectando...' : 'Iniciar Sesión',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),
                    // Cambiar entre Login y Registro
                    Center(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _isRegisterMode = !_isRegisterMode;
                          });
                        },
                        child: Text(
                          _isRegisterMode
                              ? '¿Ya tienes cuenta? Inicia sesión aquí'
                              : '¿No tienes cuenta? Regístrate aquí',
                          style: const TextStyle(
                            color: SalonGlittColors.royalPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Usuario Autenticado
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: SalonGlittColors.softPink.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: SalonGlittColors.metallicGold,
                        ),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: SalonGlittColors.royalPurple,
                            child: Icon(
                              Icons.person,
                              color: SalonGlittColors.lightGold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_apiService.currentUser?['nombre'] ?? 'Usuario'} ${_apiService.currentUser?['apellido'] ?? ''}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: SalonGlittColors.deepPurple,
                                  ),
                                ),
                                Text(
                                  _apiService.currentUser?['email'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _fetchServicios,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: SalonGlittColors.royalPurple,
                              foregroundColor: SalonGlittColors.lightGold,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                  color: SalonGlittColors.metallicGold,
                                  width: 1.2,
                                ),
                              ),
                            ),
                            icon: const Icon(Icons.room_service_outlined),
                            label: const Text('Ver Servicios'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _handleLogout,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: SalonGlittColors.hotPink,
                              side: const BorderSide(
                                color: SalonGlittColors.hotPink,
                                width: 1.4,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.logout),
                            label: const Text('Cerrar Sesión'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Monitor de Respuestas
            Container(
              decoration: BoxDecoration(
                color: SalonGlittColors.terminalBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: SalonGlittColors.metallicGold.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        color: SalonGlittColors.metallicGold,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Monitor SGE-API',
                        style: TextStyle(
                          color: SalonGlittColors.lightGold,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isOnline
                              ? SalonGlittColors.metallicGold
                              : SalonGlittColors.hotPink,
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 20),
                  SelectableText(
                    _statusMessage,
                    style: const TextStyle(
                      color: Color(0xFFFFEFA6),
                      fontFamily: 'monospace',
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
