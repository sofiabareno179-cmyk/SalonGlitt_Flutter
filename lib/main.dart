import 'package:flutter/material.dart';

import 'config/api_config.dart';
import 'services/salon_glitt_service.dart';

void main() {
  runApp(const SalonGlittApp());
}

class SalonGlittColors {
  static const Color deepPurple = Color(0xFF2E0854);
  static const Color royalPurple = Color(0xFF5B1889);
  static const Color brightPurple = Color(0xFF7B1FA2);
  static const Color hotPink = Color(0xFFE91E63);
  static const Color softPink = Color(0xFFFCE4EC);
  static const Color lightBlush = Color(0xFFFAF5FA);
  static const Color metallicGold = Color(0xFFD4AF37);
  static const Color lightGold = Color(0xFFFFE082);
  static const Color terminalBg = Color(0xFF180326);
}

class SalonGlittApp extends StatelessWidget {
  const SalonGlittApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SalonGlitt',
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
  const SalonGlittHomePage({super.key, this.apiService});

  final SalonGlittService? apiService;

  @override
  State<SalonGlittHomePage> createState() => _SalonGlittHomePageState();
}

class _SalonGlittHomePageState extends State<SalonGlittHomePage> {
  late final SalonGlittService _apiService;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nombreuserController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  bool _isRegisterMode = false;
  bool _isLoading = false;
  bool _isCheckingHealth = false;
  bool _isOnline = false;
  bool _isPasswordVisible = false;
  String _statusMessage = 'Comprobando el estado del servicio...';
  List<Map<String, dynamic>> _services = [];

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? SalonGlittService();
    _checkServerHealth();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nombreuserController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _checkServerHealth() async {
    setState(() => _isCheckingHealth = true);
    try {
      final health = await _apiService.checkHealth();
      if (!mounted) return;
      setState(() {
        _isOnline = true;
        _statusMessage =
            '${health['service'] ?? 'SGE-API'} está disponible '
            '(versión ${health['version'] ?? 'desconocida'}).';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isOnline = false;
        _statusMessage = 'No se pudo conectar con la API: $error';
      });
    } finally {
      if (mounted) setState(() => _isCheckingHealth = false);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: isError
              ? SalonGlittColors.hotPink
              : SalonGlittColors.royalPurple,
          content: Text(message),
        ),
      );
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.length < 3 || email.length > 100) {
      _showMessage(
        'El correo debe tener entre 3 y 100 caracteres.',
        isError: true,
      );
      return;
    }
    if (password.length < 8 || password.length > 128) {
      _showMessage(
        'La contraseña debe tener entre 8 y 128 caracteres.',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _apiService.login(email: email, password: password);
      final profile = await _apiService.getProfile();
      final nombreuser = profile['nombreuser']?.toString() ?? 'cliente';
      if (!mounted) return;
      setState(() {
        _isOnline = true;
        _statusMessage = 'Sesión iniciada como $nombreuser.';
      });
      _showMessage('¡Bienvenido/a, $nombreuser!');
    } catch (error) {
      if (!mounted) return;
      setState(() => _statusMessage = 'No se pudo iniciar sesión: $error');
      _showMessage('No se pudo iniciar sesión: $error', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRegister() async {
    final nombreuser = _nombreuserController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final telefono = _telefonoController.text.trim();

    if (nombreuser.isEmpty || nombreuser.length > 100) {
      _showMessage(
        'El nombre debe tener entre 1 y 100 caracteres.',
        isError: true,
      );
      return;
    }
    if (email.length < 3 || email.length > 100) {
      _showMessage(
        'El correo debe tener entre 3 y 100 caracteres.',
        isError: true,
      );
      return;
    }
    if (password.length < 8 || password.length > 128) {
      _showMessage(
        'La contraseña debe tener entre 8 y 128 caracteres.',
        isError: true,
      );
      return;
    }
    if (telefono.length > 20) {
      _showMessage(
        'El teléfono no debe superar los 20 caracteres.',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = await _apiService.register(
        nombreuser: nombreuser,
        email: email,
        password: password,
        telefono: telefono.isEmpty ? null : telefono,
      );
      if (!mounted) return;
      setState(() {
        _isOnline = true;
        _statusMessage =
            'Cuenta creada: ${user['nombreuser']} · ${user['email']} · '
            'rol ${user['rol']}. Inicia sesión para continuar.';
        _isRegisterMode = false;
        _emailController.text = email;
        _passwordController.clear();
      });
      _showMessage('Cuenta creada. Ya puedes iniciar sesión.');
    } catch (error) {
      if (!mounted) return;
      setState(() => _statusMessage = 'No se pudo crear la cuenta: $error');
      _showMessage('No se pudo crear la cuenta: $error', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchServicios() async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiService.getAuthenticated(ApiConfig.servicios);
      if (data is! List) {
        throw const FormatException(
          'La API esperaba devolver una lista de servicios.',
        );
      }
      final services = <Map<String, dynamic>>[];
      for (final item in data) {
        if (item is! Map) {
          throw const FormatException(
            'La API devolvió un servicio con formato inválido.',
          );
        }
        services.add(Map<String, dynamic>.from(item));
      }
      if (!mounted) return;
      setState(() {
        _services = services;
        _statusMessage = services.isEmpty
            ? 'La API no tiene servicios registrados.'
            : 'Se cargaron ${services.length} servicios desde ${ApiConfig.servicios}.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(
        () => _statusMessage = 'No se pudieron cargar los servicios: $error',
      );
      _showMessage(
        'No se pudieron cargar los servicios: $error',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleLogout() {
    setState(() {
      _apiService.logout();
      _services = [];
      _statusMessage = 'Sesión cerrada.';
    });
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? helper,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      helperText: helper,
      prefixIcon: Icon(icon, color: SalonGlittColors.royalPurple),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFFCFAFD),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE8DFEC)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE8DFEC)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: SalonGlittColors.royalPurple,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildBrandHeader() {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [SalonGlittColors.royalPurple, SalonGlittColors.hotPink],
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: SalonGlittColors.royalPurple.withValues(alpha: 0.2),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(Icons.spa, color: SalonGlittColors.lightGold),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SalonGlitt',
              style: TextStyle(
                color: SalonGlittColors.deepPurple,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
            Text(
              'Belleza, cuidado y bienestar',
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _isOnline
                ? const Color(0xFFE9F7EF)
                : const Color(0xFFFFF0F3),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.circle,
                size: 9,
                color: _isOnline
                    ? const Color(0xFF25834A)
                    : SalonGlittColors.hotPink,
              ),
              const SizedBox(width: 7),
              Text(
                _isOnline ? 'API en línea' : 'API sin conexión',
                style: TextStyle(
                  color: _isOnline
                      ? const Color(0xFF206D40)
                      : SalonGlittColors.hotPink,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomePanel() {
    return Container(
      constraints: const BoxConstraints(minHeight: 390),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [SalonGlittColors.deepPurple, SalonGlittColors.royalPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: SalonGlittColors.deepPurple.withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned(
            right: -6,
            top: 4,
            child: Icon(
              Icons.auto_awesome,
              color: SalonGlittColors.lightGold,
              size: 34,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: SalonGlittColors.metallicGold.withValues(alpha: 0.8),
                  ),
                ),
                child: const Icon(
                  Icons.spa_outlined,
                  color: SalonGlittColors.lightGold,
                  size: 30,
                ),
              ),
              const SizedBox(height: 72),
              Text(
                _apiService.isAuthenticated
                    ? 'Qué gusto verte de nuevo'
                    : _isRegisterMode
                    ? 'Tu momento de cuidado comienza aquí'
                    : 'Un espacio para sentirte increíble',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                _apiService.isAuthenticated
                    ? 'Consulta los servicios disponibles y encuentra tu próximo favorito.'
                    : 'Accede a tus servicios y descubre una experiencia de belleza hecha para ti.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.82),
                  fontSize: 15,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 26),
              const Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: SalonGlittColors.lightGold,
                    size: 19,
                  ),
                  SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Una experiencia sencilla, personal y segura',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              Text(
                'CONECTADO A SGE-API',
                style: TextStyle(
                  color: SalonGlittColors.lightGold.withValues(alpha: 0.9),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                ApiConfig.baseUrl,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAuthPanel() {
    if (_apiService.isAuthenticated) return _buildAccountPanel();

    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF0E8F2)),
        boxShadow: [
          BoxShadow(
            color: SalonGlittColors.deepPurple.withValues(alpha: 0.07),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _isRegisterMode ? 'Crear cuenta' : 'Bienvenida de vuelta',
            style: const TextStyle(
              color: SalonGlittColors.deepPurple,
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            _isRegisterMode
                ? 'Completa tus datos para unirte a SalonGlitt.'
                : 'Inicia sesión para continuar con tu experiencia.',
            style: const TextStyle(color: Colors.black54, height: 1.4),
          ),
          const SizedBox(height: 24),
          if (_isRegisterMode) ...[
            TextField(
              key: const Key('nombreuser-field'),
              controller: _nombreuserController,
              maxLength: 100,
              textCapitalization: TextCapitalization.words,
              decoration: _inputDecoration(
                label: 'Nombre completo',
                icon: Icons.person_outline,
                helper: 'El mismo campo nombreuser que recibe la API.',
              ),
            ),
            const SizedBox(height: 6),
          ],
          TextField(
            key: const Key('email-field'),
            controller: _emailController,
            maxLength: 100,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            decoration: _inputDecoration(
              label: 'Correo electrónico',
              icon: Icons.alternate_email_rounded,
            ),
          ),
          const SizedBox(height: 8),
          if (_isRegisterMode) ...[
            TextField(
              key: const Key('telefono-field'),
              controller: _telefonoController,
              maxLength: 20,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration(
                label: 'Teléfono (opcional)',
                icon: Icons.phone_outlined,
              ),
            ),
            const SizedBox(height: 8),
          ],
          TextField(
            key: const Key('password-field'),
            controller: _passwordController,
            maxLength: 128,
            obscureText: !_isPasswordVisible,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) =>
                _isRegisterMode ? _handleRegister() : _handleLogin(),
            decoration: _inputDecoration(
              label: 'Contraseña',
              icon: Icons.lock_outline_rounded,
              helper: _isRegisterMode ? 'Entre 8 y 128 caracteres.' : null,
              suffix: IconButton(
                tooltip: _isPasswordVisible
                    ? 'Ocultar contraseña'
                    : 'Mostrar contraseña',
                onPressed: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: SalonGlittColors.royalPurple,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: _isLoading
                  ? null
                  : _isRegisterMode
                  ? _handleRegister
                  : _handleLogin,
              style: FilledButton.styleFrom(
                backgroundColor: SalonGlittColors.royalPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: _isLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      _isRegisterMode ? Icons.person_add_alt_1 : Icons.login,
                    ),
              label: Text(
                _isLoading
                    ? 'Conectando...'
                    : _isRegisterMode
                    ? 'Crear mi cuenta'
                    : 'Iniciar sesión',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _isLoading
                ? null
                : () => setState(() => _isRegisterMode = !_isRegisterMode),
            child: Text(
              _isRegisterMode
                  ? '¿Ya tienes cuenta? Inicia sesión'
                  : '¿Primera vez aquí? Crea tu cuenta',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountPanel() {
    final user = _apiService.currentUser ?? const <String, dynamic>{};
    final name = user['nombreuser']?.toString() ?? 'Cliente';
    final email = user['email']?.toString() ?? '';
    final phone = user['telefono']?.toString();
    final role = user['rol']?.toString() ?? 'cliente';

    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF0E8F2)),
        boxShadow: [
          BoxShadow(
            color: SalonGlittColors.deepPurple.withValues(alpha: 0.07),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Tu cuenta',
            style: TextStyle(
              color: SalonGlittColors.deepPurple,
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 22),
          CircleAvatar(
            radius: 29,
            backgroundColor: SalonGlittColors.softPink,
            child: Text(
              name.isEmpty ? 'S' : name[0].toUpperCase(),
              style: const TextStyle(
                color: SalonGlittColors.royalPurple,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            name,
            style: const TextStyle(
              color: SalonGlittColors.deepPurple,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(email, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _accountTag(Icons.badge_outlined, 'Rol: $role'),
              if (phone != null && phone.isNotEmpty)
                _accountTag(Icons.phone_outlined, phone),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _isLoading ? null : _fetchServicios,
                  icon: const Icon(Icons.auto_awesome_mosaic_outlined),
                  label: const Text('Ver servicios'),
                  style: FilledButton.styleFrom(
                    backgroundColor: SalonGlittColors.royalPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: _isLoading ? null : _handleLogout,
                style: OutlinedButton.styleFrom(
                  foregroundColor: SalonGlittColors.hotPink,
                  side: const BorderSide(color: SalonGlittColors.hotPink),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 12,
                  ),
                ),
                child: const Icon(Icons.logout_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _accountTag(IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: SalonGlittColors.lightBlush,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: SalonGlittColors.royalPurple),
          const SizedBox(width: 6),
          Text(value, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildApiStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0E8F2)),
      ),
      child: Row(
        children: [
          Icon(
            _isOnline ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
            color: _isOnline
                ? const Color(0xFF25834A)
                : SalonGlittColors.hotPink,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isOnline ? 'Servicio disponible' : 'Estado de la API',
                  style: const TextStyle(
                    color: SalonGlittColors.deepPurple,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _statusMessage,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Comprobar conexión',
            onPressed: _isCheckingHealth ? null : _checkServerHealth,
            icon: _isCheckingHealth
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildServices() {
    if (!_apiService.isAuthenticated || _services.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Servicios disponibles',
          style: TextStyle(
            color: SalonGlittColors.deepPurple,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        ..._services.map((service) {
          final rawPrice = service['precio'];
          final price = rawPrice is num
              ? rawPrice
              : num.tryParse(rawPrice?.toString() ?? '');
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFF0E8F2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: SalonGlittColors.softPink,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.spa_outlined,
                    color: SalonGlittColors.royalPurple,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service['nombre']?.toString() ?? 'Servicio',
                        style: const TextStyle(
                          color: SalonGlittColors.deepPurple,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${service['categoria'] ?? 'Sin categoría'} · '
                        '${service['duracion'] ?? 'Duración no indicada'}',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  price == null ? 'Consultar' : price.toStringAsFixed(2),
                  style: const TextStyle(
                    color: SalonGlittColors.royalPurple,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFCF8FD), SalonGlittColors.lightBlush],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWide ? 32 : 20,
                      vertical: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildBrandHeader(),
                        const SizedBox(height: 28),
                        if (isWide)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 5, child: _buildWelcomePanel()),
                              const SizedBox(width: 22),
                              Expanded(flex: 6, child: _buildAuthPanel()),
                            ],
                          )
                        else ...[
                          _buildWelcomePanel(),
                          const SizedBox(height: 18),
                          _buildAuthPanel(),
                        ],
                        const SizedBox(height: 18),
                        _buildApiStatus(),
                        if (_apiService.isAuthenticated) ...[
                          const SizedBox(height: 26),
                          _buildServices(),
                        ],
                        const SizedBox(height: 18),
                        const Center(
                          child: Text(
                            'SalonGlitt · Cuidado con estilo',
                            style: TextStyle(
                              color: Colors.black45,
                              fontSize: 12,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
