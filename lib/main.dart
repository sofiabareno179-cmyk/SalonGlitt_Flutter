import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'config/api_config.dart';
import 'services/salon_glitt_service.dart';

void main() {
  runApp(const SalonGlittApp());
}

class SalonGlittColors {
  // Paleta boutique: Morado Pastel, Rosa Pastel y Dorado
  static const Color deepPurple = Color(
    0xFF5C3C75,
  ); // Morado pastel profundo para degradados
  static const Color royalPurple = Color(
    0xFF7E5B9B,
  ); // Morado pastel principal (elegante y legible)
  static const Color brightPurple = Color(0xFF9872B5); // Morado pastel luminoso
  static const Color berryPlum = Color(0xFF6E4984); // Morado pastel intermedio
  static const Color hotPink = Color(
    0xFFE5829D,
  ); // Rosa pastel acento (suave y chic)
  static const Color softPink = Color(
    0xFFFDE8F0,
  ); // Rosa pastel suave para fondos y tarjetas
  static const Color pastelRose = Color(
    0xFFF8CAD7,
  ); // Rosa pastel para bordes y acentos
  static const Color lightBlush = Color(0xFFFAF6FA); // Fondo lienzo limpio
  static const Color champagne = Color(0xFFFDFBF7); // Champagne cálido
  static const Color metallicGold = Color(0xFFD4AF37); // Dorado elegante
  static const Color lightGold = Color(0xFFFFE38C); // Dorado iluminado
  static const Color softLavender = Color(
    0xFFF2EAF7,
  ); // Lavanda / Morado pastel suave
  static const Color cardBorder = Color(0xFFECE1EF); // Borde delicado
  static const Color textDark = Color(
    0xFF2C1938,
  ); // Texto oscuro con matiz suave
  static const Color textMuted = Color(0xFF7A6686); // Texto secundario
  static const Color successGreen = Color(0xFF1E874B);
  static const Color successBg = Color(0xFFE8F6EE);
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
          surface: Colors.white,
          brightness: Brightness.light,
        ),
        fontFamily: 'Segoe UI',
        useMaterial3: true,
      ),
      home: const SalonGlittHomePage(),
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.radius,
    required this.initial,
    required this.photoUrl,
    this.photoBytes,
    this.emoji = '',
    this.backgroundColor,
    this.textColor,
    this.fontSize = 13,
  });

  final double radius;
  final String initial;
  final String photoUrl;
  final Uint8List? photoBytes;
  final String emoji;
  final Color? backgroundColor;
  final Color? textColor;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    Widget content;
    if (photoBytes != null && photoBytes!.isNotEmpty) {
      content = Image.memory(
        photoBytes!,
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    } else if (emoji.isNotEmpty) {
      content = Center(
        child: Text(
          emoji,
          style: TextStyle(fontSize: radius * 0.95, height: 1),
        ),
      );
    } else if (photoUrl.isNotEmpty) {
      content = Image.network(
        photoUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _initialText(),
      );
    } else {
      content = _initialText();
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? SalonGlittColors.softPink,
      child: ClipOval(
        child: SizedBox(width: size, height: size, child: content),
      ),
    );
  }

  Widget _initialText() {
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          color: textColor ?? SalonGlittColors.royalPurple,
          fontWeight: FontWeight.w800,
          fontSize: fontSize,
        ),
      ),
    );
  }
}

class AnimatedAvatar extends StatefulWidget {
  const AnimatedAvatar({
    super.key,
    required this.radius,
    required this.initial,
    required this.photoUrl,
    this.photoBytes,
    this.emoji = '',
    this.backgroundColor,
    this.textColor,
    this.fontSize = 13,
    this.offset = 3,
  });

  final double radius;
  final String initial;
  final String photoUrl;
  final Uint8List? photoBytes;
  final String emoji;
  final Color? backgroundColor;
  final Color? textColor;
  final double fontSize;
  final double offset;

  @override
  State<AnimatedAvatar> createState() => _AnimatedAvatarState();
}

class _AnimatedAvatarState extends State<AnimatedAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat(reverse: true);
  late final Animation<double> _dy = Tween<double>(
    begin: -widget.offset,
    end: widget.offset,
  ).animate(_controller);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) =>
          Transform.translate(offset: Offset(0, _dy.value), child: child),
      child: ProfileAvatar(
        radius: widget.radius,
        initial: widget.initial,
        photoUrl: widget.photoUrl,
        photoBytes: widget.photoBytes,
        emoji: widget.emoji,
        backgroundColor: widget.backgroundColor,
        textColor: widget.textColor,
        fontSize: widget.fontSize,
      ),
    );
  }
}

class _AvatarOption {
  const _AvatarOption({
    required this.id,
    required this.label,
    required this.bgColor,
    this.emoji,
    this.imageUrl,
  });

  final String id;
  final String label;
  final Color bgColor;
  final String? emoji;
  final String? imageUrl;

  bool get isEmoji => emoji != null && emoji!.isNotEmpty;
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

  // Estados de navegación e interfaz
  int _currentTabIndex = 0; // 0: Inicio, 1: Servicios, 2: Citas, 3: Perfil
  String _selectedCategory = 'Todos';
  String _serviceSearchQuery = '';

  Map<String, dynamic>? _localUserProfile;
  String _profilePhotoUrl = '';
  String _avatarEmoji = '🦋';
  Uint8List? _profilePhotoBytes;
  final List<_AvatarOption> _avatarOptions = const [
    _AvatarOption(
      id: 'emoji-spa',
      label: 'Spa',
      emoji: '🦋',
      bgColor: Color(0xFFFCE4EC),
    ),
    _AvatarOption(
      id: 'emoji-reina',
      label: 'Reina',
      emoji: '👸',
      bgColor: Color(0xFFFFF3E0),
    ),
    _AvatarOption(
      id: 'emoji-nails',
      label: 'Nails',
      emoji: '💅',
      bgColor: Color(0xFFF3E5F5),
    ),
    _AvatarOption(
      id: 'emoji-flores',
      label: 'Flores',
      emoji: '🌸',
      bgColor: Color(0xFFE8F5E9),
    ),
    _AvatarOption(
      id: 'personaje-amiga',
      label: 'Amiga',
      imageUrl:
          'https://api.dicebear.com/9.x/adventurer/png?seed=Salon&size=128',
      bgColor: Color(0xFFE3F2FD),
    ),
    _AvatarOption(
      id: 'personaje-clienta',
      label: 'Clienta',
      imageUrl:
          'https://api.dicebear.com/9.x/avataaars/png?seed=Glitt&size=128',
      bgColor: Color(0xFFFFEBEE),
    ),
    _AvatarOption(
      id: 'personaje-robot',
      label: 'Robot',
      imageUrl: 'https://api.dicebear.com/9.x/bottts/png?seed=Beauty&size=128',
      bgColor: Color(0xFFF1F8E9),
    ),
    _AvatarOption(
      id: 'personaje-lorelei',
      label: 'Lorelei',
      imageUrl: 'https://api.dicebear.com/9.x/lorelei/png?seed=Brillo&size=128',
      bgColor: Color(0xFFFFF8E1),
    ),
  ];
  bool _whatsappNotifications = true;
  bool _emailPromos = true;

  bool _isRegisterMode = false;
  bool _isLoading = false;
  bool _isCheckingHealth = false;
  bool _isOnline = false;
  bool _isPasswordVisible = false;
  String _statusMessage = 'Comprobando el estado del servicio...';
  List<Map<String, dynamic>> _services = [];

  // Lista local interactiva de citas del usuario
  final List<Map<String, dynamic>> _userAppointments = [
    {
      'id': 'cita-01',
      'servicio': 'Manicura Spa & Esmaltado',
      'categoria': 'Uñas',
      'fecha': 'Sábado, 24 de Octubre',
      'hora': '10:30 AM',
      'profesional': 'Camila R. · Especialista en uñas',
      'estado': 'Confirmada',
      'precio': 32.0,
    },
    {
      'id': 'cita-02',
      'servicio': 'Limpieza Facial Hidratante',
      'categoria': 'Facial & Spa',
      'fecha': 'Jueves, 29 de Octubre',
      'hora': '04:00 PM',
      'profesional': 'Elena V. · Cosmetóloga',
      'estado': 'Programada',
      'precio': 45.0,
    },
  ];

  // Servicios predeterminados para una experiencia visual completa de salón
  final List<Map<String, dynamic>> _curatedServices = [
    {
      'id': 1,
      'nombre': 'Corte y Estilizado Signature',
      'categoria': 'Cabello',
      'duracion': '45 min',
      'precio': 28.0,
      'icono': Icons.content_cut_rounded,
      'imagen':
          'https://images.unsplash.com/photo-1560869713-7d0a29430803?w=600&auto=format&fit=crop&q=80',
      'descripcion':
          'Asesoría de imagen, lavado nutritivo, corte personalizado y peinado.',
      'calificacion': 4.9,
    },
    {
      'id': 2,
      'nombre': 'Balayage & Matiz Iluminación',
      'categoria': 'Cabello',
      'duracion': '120 min',
      'precio': 65.0,
      'icono': Icons.auto_awesome_rounded,
      'imagen':
          'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=600&auto=format&fit=crop&q=80',
      'descripcion':
          'Degradado natural con técnica personalizada y sellado de brillo.',
      'calificacion': 5.0,
    },
    {
      'id': 3,
      'nombre': 'Manicura Rusa & Semipermanente',
      'categoria': 'Uñas',
      'duracion': '60 min',
      'precio': 32.0,
      'icono': Icons.brush_rounded,
      'imagen':
          'https://images.unsplash.com/photo-1632345031435-8727f6897d53?w=600&auto=format&fit=crop&q=80',
      'descripcion':
          'Limpieza profunda de cutículas, esmaltado de alta duración y brillo.',
      'calificacion': 4.9,
    },
    {
      'id': 4,
      'nombre': 'Pedicura Spa Relajante',
      'categoria': 'Uñas',
      'duracion': '50 min',
      'precio': 30.0,
      'icono': Icons.spa_rounded,
      'imagen':
          'https://images.unsplash.com/photo-1519014816548-bf5fe059798b?w=600&auto=format&fit=crop&q=80',
      'descripcion':
          'Exfoliación con sales minerales, masaje hidratante y esmaltado.',
      'calificacion': 4.8,
    },
    {
      'id': 5,
      'nombre': 'Limpieza Facial Profunda & Glow',
      'categoria': 'Facial & Spa',
      'duracion': '70 min',
      'precio': 45.0,
      'icono': Icons.face_retouching_natural_rounded,
      'imagen':
          'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?w=600&auto=format&fit=crop&q=80',
      'descripcion':
          'Extracción ultrasónica, mascarilla de ácido hialurónico y velo de luz.',
      'calificacion': 4.9,
    },
    {
      'id': 6,
      'nombre': 'Masaje Relajante Aromaterapia',
      'categoria': 'Facial & Spa',
      'duracion': '60 min',
      'precio': 40.0,
      'icono': Icons.self_improvement_rounded,
      'imagen':
          'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?w=600&auto=format&fit=crop&q=80',
      'descripcion':
          'Alivio del estrés corporal con aceites esenciales de lavanda y cítricos.',
      'calificacion': 5.0,
    },
    {
      'id': 7,
      'nombre': 'Lifting de Pestañas & Laminado de Cejas',
      'categoria': 'Pestañas & Cejas',
      'duracion': '50 min',
      'precio': 35.0,
      'icono': Icons.visibility_rounded,
      'imagen':
          'https://images.unsplash.com/photo-1583001809873-a128495da465?w=600&auto=format&fit=crop&q=80',
      'descripcion':
          'Curvatura natural duradera con tinte de queratina y diseño de mirada.',
      'calificacion': 4.8,
    },
    {
      'id': 8,
      'nombre': 'Maquillaje Social & Glamour',
      'categoria': 'Maquillaje',
      'duracion': '60 min',
      'precio': 50.0,
      'icono': Icons.auto_fix_high_rounded,
      'imagen':
          'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=600&auto=format&fit=crop&q=80',
      'descripcion':
          'Look sofisticado de larga duración para eventos especiales y sesiones.',
      'calificacion': 4.9,
    },
  ];

  String _getServiceImageUrl(Map<String, dynamic> service) {
    final direct =
        service['imagen']?.toString() ??
        service['foto']?.toString() ??
        service['image']?.toString();
    if (direct != null && direct.isNotEmpty) return direct;

    final name = (service['nombre']?.toString() ?? '').toLowerCase();
    final cat = (service['categoria']?.toString() ?? '').toLowerCase();

    if (name.contains('balayage')) {
      return 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=600&auto=format&fit=crop&q=80';
    }
    if (name.contains('corte') || cat.contains('cabello')) {
      return 'https://images.unsplash.com/photo-1560869713-7d0a29430803?w=600&auto=format&fit=crop&q=80';
    }
    if (name.contains('pedicura')) {
      return 'https://images.unsplash.com/photo-1519014816548-bf5fe059798b?w=600&auto=format&fit=crop&q=80';
    }
    if (name.contains('uñas') ||
        cat.contains('uña') ||
        name.contains('manicura')) {
      return 'https://images.unsplash.com/photo-1632345031435-8727f6897d53?w=600&auto=format&fit=crop&q=80';
    }
    if (name.contains('facial') ||
        cat.contains('facial') ||
        name.contains('limpieza')) {
      return 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?w=600&auto=format&fit=crop&q=80';
    }
    if (name.contains('masaje') || cat.contains('spa')) {
      return 'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?w=600&auto=format&fit=crop&q=80';
    }
    if (name.contains('pestaña') ||
        name.contains('ceja') ||
        cat.contains('ceja')) {
      return 'https://images.unsplash.com/photo-1583001809873-a128495da465?w=600&auto=format&fit=crop&q=80';
    }
    if (name.contains('maquillaje') || cat.contains('maquillaje')) {
      return 'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=600&auto=format&fit=crop&q=80';
    }
    return 'https://images.unsplash.com/photo-1560869713-7d0a29430803?w=600&auto=format&fit=crop&q=80';
  }

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
            '${health['service'] ?? 'SGE-API'} conectado '
            '(versión ${health['version'] ?? '1.0'}).';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isOnline = false;
        _statusMessage = 'Sin conexión con la API: $error';
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
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: isError
              ? SalonGlittColors.hotPink
              : SalonGlittColors.royalPurple,
          content: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
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
        _localUserProfile = profile;
        _isOnline = true;
        _currentTabIndex = 0;
        _statusMessage = 'Sesión iniciada como $nombreuser.';
      });
      _showMessage('¡Bienvenido/a a SalonGlitt, $nombreuser!');
      _fetchServicios();
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
            'Cuenta creada: ${user['nombreuser']}. Inicia sesión para continuar.';
        _isRegisterMode = false;
        _emailController.text = email;
        _passwordController.clear();
      });
      _showMessage('Cuenta creada con éxito. Ya puedes iniciar sesión.');
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
        if (item is Map) {
          services.add(Map<String, dynamic>.from(item));
        }
      }
      if (!mounted) return;
      setState(() {
        _services = services;
        _statusMessage = services.isEmpty
            ? 'Catálogo en línea sincronizado.'
            : '${services.length} servicios cargados desde la API.';
      });
    } catch (_) {
      // Si la API remota aún no tiene el catálogo cargado, conservamos la vista curada limpia
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleLogout() {
    setState(() {
      _apiService.logout();
      _localUserProfile = null;
      _services = [];
      _currentTabIndex = 0;
      _statusMessage = 'Sesión cerrada con éxito.';
    });
    _showMessage('Has cerrado sesión correctamente.');
  }

  // Lista combinada de servicios (API + curados para máxima calidad estética)
  List<Map<String, dynamic>> get _allDisplayServices {
    if (_services.isNotEmpty) {
      return _services;
    }
    return _curatedServices;
  }

  List<Map<String, dynamic>> get _filteredServices {
    return _allDisplayServices.where((s) {
      final matchesCategory =
          _selectedCategory == 'Todos' ||
          (s['categoria']?.toString().toLowerCase().contains(
                _selectedCategory.toLowerCase(),
              ) ??
              false);
      final matchesSearch =
          _serviceSearchQuery.isEmpty ||
          (s['nombre']?.toString().toLowerCase().contains(
                _serviceSearchQuery.toLowerCase(),
              ) ??
              false);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  // Modal interactivo para agendar cita con el servicio seleccionado
  void _openBookingModal(Map<String, dynamic> service) {
    String selectedDate = 'Mañana (10:00 AM)';
    String selectedSpecialist = 'Especialista recomendada';
    final serviceName = service['nombre']?.toString() ?? 'Servicio';
    final rawPrice = service['precio'];
    final price = rawPrice is num
        ? rawPrice.toDouble()
        : (double.tryParse(rawPrice?.toString() ?? '') ?? 30.0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(28, 20, 28, 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: SalonGlittColors.softPink,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.calendar_month_rounded,
                          color: SalonGlittColors.royalPurple,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Reservar Cita',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: SalonGlittColors.textDark,
                              ),
                            ),
                            Text(
                              serviceName,
                              style: const TextStyle(
                                color: SalonGlittColors.textMuted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '\$${price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: SalonGlittColors.royalPurple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Selecciona horario disponible',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: SalonGlittColors.textDark,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        [
                          'Mañana (10:00 AM)',
                          'Mañana (03:30 PM)',
                          'Sábado (11:00 AM)',
                          'Sábado (05:00 PM)',
                        ].map((slot) {
                          final isSelected = selectedDate == slot;
                          return ChoiceChip(
                            label: Text(slot),
                            selected: isSelected,
                            selectedColor: SalonGlittColors.royalPurple,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : SalonGlittColors.textDark,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            backgroundColor: SalonGlittColors.softLavender,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected
                                    ? SalonGlittColors.royalPurple
                                    : Colors.transparent,
                              ),
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setModalState(() => selectedDate = slot);
                              }
                            },
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Profesional asignada',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: SalonGlittColors.textDark,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children:
                        [
                          'Especialista recomendada',
                          'Valeria M.',
                          'Camila R.',
                        ].map((spec) {
                          final isSelected = selectedSpecialist == spec;
                          return ChoiceChip(
                            avatar: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Text(
                                spec[0],
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: SalonGlittColors.royalPurple,
                                ),
                              ),
                            ),
                            label: Text(spec),
                            selected: isSelected,
                            selectedColor: SalonGlittColors.royalPurple,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : SalonGlittColors.textDark,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            backgroundColor: SalonGlittColors.softLavender,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected
                                    ? SalonGlittColors.royalPurple
                                    : Colors.transparent,
                              ),
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setModalState(() => selectedSpecialist = spec);
                              }
                            },
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        _userAppointments.insert(0, {
                          'id': 'cita-${DateTime.now().millisecondsSinceEpoch}',
                          'servicio': serviceName,
                          'categoria': service['categoria'] ?? 'Servicio',
                          'fecha': selectedDate.split('(')[0].trim(),
                          'hora': selectedDate.contains('(')
                              ? selectedDate.split('(')[1].replaceAll(')', '')
                              : '10:00 AM',
                          'profesional': selectedSpecialist,
                          'estado': 'Confirmada',
                          'precio': price,
                        });
                        _currentTabIndex = 2; // Ir a la pestaña Citas
                      });
                      _showMessage('¡Cita confirmada para $serviceName! ✨');
                    },
                    icon: const Icon(Icons.check_circle_rounded),
                    label: const Text('Confirmar Reserva'),
                    style: FilledButton.styleFrom(
                      backgroundColor: SalonGlittColors.royalPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Modal limpio con los detalles técnicos de la API (oculto de la pantalla principal)
  void _showServerStatusDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _isOnline
                      ? SalonGlittColors.successBg
                      : const Color(0xFFFFF0F3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _isOnline
                      ? Icons.cloud_done_rounded
                      : Icons.cloud_off_rounded,
                  color: _isOnline
                      ? SalonGlittColors.successGreen
                      : SalonGlittColors.hotPink,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Estado del Servidor',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: SalonGlittColors.textDark,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isOnline
                    ? 'Servicio SGE-API Operativo'
                    : 'Servicio Desconectado',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: _isOnline
                      ? SalonGlittColors.successGreen
                      : SalonGlittColors.hotPink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _statusMessage,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
              const Divider(height: 28),
              const Text(
                'URL BASE CONECTADA',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: SalonGlittColors.textMuted,
                ),
              ),
              const SizedBox(height: 4),
              SelectableText(
                ApiConfig.baseUrl,
                style: const TextStyle(
                  fontSize: 11,
                  color: SalonGlittColors.royalPurple,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _checkServerHealth();
              },
              icon: _isCheckingHealth
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Reconectar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                backgroundColor: SalonGlittColors.royalPurple,
              ),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  // Encabezado moderno, elegante y limpio
  Widget _buildTopNavBar(bool isWide) {
    final user = _localUserProfile ?? _apiService.currentUser;
    final userName = user?['nombreuser']?.toString() ?? 'Cliente';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: SalonGlittColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: SalonGlittColors.deepPurple.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo & Título
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  SalonGlittColors.royalPurple,
                  SalonGlittColors.hotPink,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: SalonGlittColors.royalPurple.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.spa,
              color: SalonGlittColors.lightGold,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'SalonGlitt',
                style: TextStyle(
                  color: SalonGlittColors.textDark,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                'Estudio de Belleza & Spa',
                style: TextStyle(
                  color: SalonGlittColors.textMuted.withValues(alpha: 0.9),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          // Pestañas integradas en desktop/pantalla ancha si está autenticado
          if (isWide && _apiService.isAuthenticated) ...[
            const SizedBox(width: 36),
            _buildNavPill(0, Icons.home_rounded, 'Inicio'),
            const SizedBox(width: 6),
            _buildNavPill(1, Icons.spa_rounded, 'Servicios'),
            const SizedBox(width: 6),
            _buildNavPill(
              2,
              Icons.calendar_today_rounded,
              'Mis Citas',
              badge: _userAppointments.length.toString(),
            ),
          ],

          const Spacer(),

          // Indicador discreto de API (con diálogo al pulsar)
          InkWell(
            onTap: _showServerStatusDialog,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: _isOnline
                    ? SalonGlittColors.successBg
                    : const Color(0xFFFFF0F3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isOnline
                      ? SalonGlittColors.successGreen.withValues(alpha: 0.25)
                      : SalonGlittColors.hotPink.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _isOnline
                          ? SalonGlittColors.successGreen
                          : SalonGlittColors.hotPink,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    _isOnline ? 'En línea' : 'Sin conexión',
                    style: TextStyle(
                      color: _isOnline
                          ? SalonGlittColors.successGreen
                          : SalonGlittColors.hotPink,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Icono único de perfil (Avatar del usuario)
          if (_apiService.isAuthenticated) ...[
            const SizedBox(width: 14),
            Tooltip(
              message: 'Mi Perfil ($userName)',
              child: InkWell(
                onTap: () => setState(() => _currentTabIndex = 3),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _currentTabIndex == 3
                          ? SalonGlittColors.royalPurple
                          : SalonGlittColors.metallicGold.withValues(
                              alpha: 0.8,
                            ),
                      width: _currentTabIndex == 3 ? 2.2 : 1.5,
                    ),
                    boxShadow: _currentTabIndex == 3
                        ? [
                            BoxShadow(
                              color: SalonGlittColors.royalPurple.withValues(
                                alpha: 0.25,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: ProfileAvatar(
                    radius: 16,
                    initial: userName.isNotEmpty
                        ? userName[0].toUpperCase()
                        : 'C',
                    photoUrl: _resolvePhotoUrl(_profilePhotoUrl),
                    photoBytes: _profilePhotoBytes,
                    emoji: _avatarEmoji,
                    backgroundColor: _currentTabIndex == 3
                        ? SalonGlittColors.royalPurple
                        : SalonGlittColors.softPink,
                    textColor: _currentTabIndex == 3
                        ? Colors.white
                        : SalonGlittColors.royalPurple,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Cerrar sesión',
              onPressed: _handleLogout,
              icon: const Icon(
                Icons.logout_rounded,
                color: SalonGlittColors.hotPink,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Barra de pestañas para vista móvil / pantallas compactas
  Widget _buildMobileTabNav() {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: SalonGlittColors.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMobileNavIcon(0, Icons.home_rounded, 'Inicio'),
          _buildMobileNavIcon(1, Icons.spa_rounded, 'Servicios'),
          _buildMobileNavIcon(
            2,
            Icons.calendar_today_rounded,
            'Citas',
            badge: _userAppointments.length.toString(),
          ),
          _buildMobileNavIcon(3, Icons.person_rounded, 'Perfil'),
        ],
      ),
    );
  }

  Widget _buildNavPill(
    int index,
    IconData icon,
    String label, {
    String? badge,
  }) {
    final isSelected = _currentTabIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentTabIndex = index),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? SalonGlittColors.softLavender
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? SalonGlittColors.royalPurple
                  : SalonGlittColors.textMuted,
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? SalonGlittColors.royalPurple
                    : SalonGlittColors.textMuted,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? SalonGlittColors.royalPurple
                      : SalonGlittColors.cardBorder,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? Colors.white
                        : SalonGlittColors.textDark,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMobileNavIcon(
    int index,
    IconData icon,
    String label, {
    String? badge,
  }) {
    final isSelected = _currentTabIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentTabIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? SalonGlittColors.softLavender
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected
                      ? SalonGlittColors.royalPurple
                      : SalonGlittColors.textMuted,
                ),
                if (badge != null && badge != '0')
                  Positioned(
                    right: -6,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: SalonGlittColors.hotPink,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? SalonGlittColors.royalPurple
                    : SalonGlittColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // PESTAÑA 0: INICIO (Dashboard elegante y no cargado)
  // -------------------------------------------------------------
  Widget _buildHomeTab(bool isWide, String userName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Banner Hero Refinado y Limpio (Sin URLs técnicas)
        Container(
          padding: EdgeInsets.all(isWide ? 36 : 24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                SalonGlittColors.deepPurple,
                SalonGlittColors.royalPurple,
                Color(0xFFB57D9D),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: SalonGlittColors.deepPurple.withValues(alpha: 0.18),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: SalonGlittColors.metallicGold.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: SalonGlittColors.lightGold,
                          size: 14,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Experiencia Exclusiva SalonGlitt',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.spa_outlined,
                    color: SalonGlittColors.lightGold,
                    size: 28,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                '¡Qué gusto verte de nuevo, $userName! ✨',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isWide ? 30 : 23,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Text(
                  'Descubre los tratamientos que resaltan tu belleza y bienestar personal. Reserva fácilmente y déjate consentir por especialistas.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed: () => setState(() => _currentTabIndex = 1),
                    icon: const Icon(Icons.spa_rounded, size: 18),
                    label: const Text('Explorar Servicios'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: SalonGlittColors.royalPurple,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => setState(() => _currentTabIndex = 2),
                    icon: const Icon(Icons.calendar_month_outlined, size: 18),
                    label: const Text('Mis Citas'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white60),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        // Fila de Estadísticas / Resumen en tarjetas limpias
        LayoutBuilder(
          builder: (context, box) {
            final cardWidth = isWide ? (box.maxWidth - 36) / 3 : box.maxWidth;
            return Wrap(
              spacing: 18,
              runSpacing: 14,
              children: [
                _buildSummaryCard(
                  width: cardWidth,
                  icon: Icons.spa_outlined,
                  iconColor: SalonGlittColors.royalPurple,
                  title: 'Servicios en Catálogo',
                  value: '${_allDisplayServices.length} disponibles',
                  subtitle: 'Cabello, Uñas, Spa & Rostro',
                ),
                _buildSummaryCard(
                  width: cardWidth,
                  icon: Icons.event_available_rounded,
                  iconColor: SalonGlittColors.hotPink,
                  title: 'Próxima Cita',
                  value: _userAppointments.isNotEmpty
                      ? _userAppointments.first['fecha'].toString().split(
                          ',',
                        )[0]
                      : 'Sin citas',
                  subtitle: _userAppointments.isNotEmpty
                      ? '${_userAppointments.first['servicio']} (${_userAppointments.first['hora']})'
                      : 'Agenda tu primera sesión',
                ),
                _buildSummaryCard(
                  width: cardWidth,
                  icon: Icons.workspace_premium_outlined,
                  iconColor: SalonGlittColors.metallicGold,
                  title: 'Membresía Glitt',
                  value: 'Cliente VIP',
                  subtitle: 'Beneficios y atención prioritaria',
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 26),

        // Servicios más populares destacados
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tratamientos Destacados',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: SalonGlittColors.textDark,
              ),
            ),
            TextButton.icon(
              onPressed: () => setState(() => _currentTabIndex = 1),
              icon: const Text(
                'Ver catálogo completo',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              label: const Icon(Icons.arrow_forward_rounded, size: 16),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Carrusel/Malla de 3 servicios destacados
        LayoutBuilder(
          builder: (context, box) {
            final count = isWide ? 3 : 1;
            final itemWidth = (box.maxWidth - ((count - 1) * 16)) / count;
            final topServices = _allDisplayServices.take(3).toList();

            return Wrap(
              spacing: 16,
              runSpacing: 14,
              children: topServices.map((service) {
                return SizedBox(
                  width: itemWidth,
                  child: _buildServiceCard(service),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required double width,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SalonGlittColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: SalonGlittColors.deepPurple.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: SalonGlittColors.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: SalonGlittColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: Colors.black45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // PESTAÑA 1: CATÁLOGO DE SERVICIOS EN CUADRÍCULA CON CATEGORÍAS
  // -------------------------------------------------------------
  Widget _buildServicesTab(bool isWide) {
    final categories = [
      'Todos',
      'Cabello',
      'Uñas',
      'Facial & Spa',
      'Pestañas & Cejas',
      'Maquillaje',
    ];

    final filtered = _filteredServices;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Encabezado de la sección
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Catálogo de Servicios',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: SalonGlittColors.textDark,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Selecciona una categoría y agenda tu sesión personalizada.',
                  style: TextStyle(
                    color: SalonGlittColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            IconButton.filledTonal(
              tooltip: 'Actualizar servicios desde la API',
              onPressed: _isLoading ? null : _fetchServicios,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync_rounded),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // Barra de búsqueda de servicios
        TextField(
          onChanged: (val) => setState(() => _serviceSearchQuery = val),
          decoration: InputDecoration(
            hintText: 'Buscar servicio (ej. corte, manicura, facial...)',
            hintStyle: const TextStyle(
              fontSize: 13,
              color: SalonGlittColors.textMuted,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: SalonGlittColors.royalPurple,
              size: 20,
            ),
            suffixIcon: _serviceSearchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    onPressed: () => setState(() => _serviceSearchQuery = ''),
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: SalonGlittColors.cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: SalonGlittColors.cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: SalonGlittColors.royalPurple,
                width: 1.5,
              ),
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Filtros de categoría con chips modernos
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((cat) {
              final isSelected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: SalonGlittColors.royalPurple,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : SalonGlittColors.textDark,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected
                          ? SalonGlittColors.royalPurple
                          : SalonGlittColors.cardBorder,
                    ),
                  ),
                  showCheckmark: false,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = cat;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 20),

        // Cuadrícula atractiva de servicios
        if (filtered.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: SalonGlittColors.cardBorder),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.spa_outlined,
                  size: 48,
                  color: SalonGlittColors.textMuted,
                ),
                const SizedBox(height: 12),
                const Text(
                  'No se encontraron servicios en esta categoría',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: SalonGlittColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: () => setState(() => _selectedCategory = 'Todos'),
                  child: const Text('Ver todos los servicios'),
                ),
              ],
            ),
          )
        else
          LayoutBuilder(
            builder: (context, box) {
              // 3 columnas en desktop amplia, 2 en pantallas medianas, 1 en móviles
              int columns = 1;
              if (box.maxWidth >= 950) {
                columns = 3;
              } else if (box.maxWidth >= 600) {
                columns = 2;
              }

              final itemWidth = (box.maxWidth - ((columns - 1) * 16)) / columns;

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: filtered.map((service) {
                  return SizedBox(
                    width: itemWidth,
                    child: _buildServiceCard(service),
                  );
                }).toList(),
              );
            },
          ),
      ],
    );
  }

  // Tarjeta individual de servicio con imagen, diseño de lujo, precio y botón de agendar
  Widget _buildServiceCard(Map<String, dynamic> service) {
    final nombre = service['nombre']?.toString() ?? 'Servicio';
    final categoria = service['categoria']?.toString() ?? 'Belleza';
    final duracion = service['duracion']?.toString() ?? '45 min';
    final rawPrice = service['precio'];
    final price = rawPrice is num
        ? rawPrice.toDouble()
        : (double.tryParse(rawPrice?.toString() ?? '') ?? 30.0);
    final rating = service['calificacion'] ?? 4.9;
    final icon = service['icono'] as IconData? ?? Icons.spa_rounded;
    final imageUrl = _getServiceImageUrl(service);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: SalonGlittColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: SalonGlittColors.deepPurple.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen del servicio con chips flotantes
          Stack(
            children: [
              Image.network(
                imageUrl,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 140,
                  color: SalonGlittColors.softPink,
                  child: Center(
                    child: Icon(
                      icon,
                      color: SalonGlittColors.royalPurple,
                      size: 36,
                    ),
                  ),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 140,
                    color: SalonGlittColors.softPink.withValues(alpha: 0.5),
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
              ),
              // Sombra degradada sutil sobre la foto
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.25),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.15),
                      ],
                    ),
                  ),
                ),
              ),
              // Chip de Categoría
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 12, color: SalonGlittColors.royalPurple),
                      const SizedBox(width: 4),
                      Text(
                        categoria.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.7,
                          color: SalonGlittColors.royalPurple,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Chip de Calificación con dorado
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: SalonGlittColors.metallicGold,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        rating.toString(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: SalonGlittColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: SalonGlittColors.textDark,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 13,
                      color: SalonGlittColors.textMuted,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      duracion,
                      style: const TextStyle(
                        fontSize: 12,
                        color: SalonGlittColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: SalonGlittColors.cardBorder),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Precio',
                          style: TextStyle(
                            fontSize: 11,
                            color: SalonGlittColors.textMuted,
                          ),
                        ),
                        Text(
                          '\$${price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: SalonGlittColors.royalPurple,
                          ),
                        ),
                      ],
                    ),
                    FilledButton.icon(
                      onPressed: () => _openBookingModal(service),
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text('Agendar'),
                      style: FilledButton.styleFrom(
                        backgroundColor: SalonGlittColors.royalPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // PESTAÑA 2: CITAS Y AGENDA
  // -------------------------------------------------------------
  Widget _buildAppointmentsTab(bool isWide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mis Citas y Agenda',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: SalonGlittColors.textDark,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Gestiona tus próximas visitas y tratamientos agendados.',
                  style: TextStyle(
                    color: SalonGlittColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            FilledButton.icon(
              onPressed: () => setState(() => _currentTabIndex = 1),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Nueva Cita'),
              style: FilledButton.styleFrom(
                backgroundColor: SalonGlittColors.royalPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        if (_userAppointments.isEmpty)
          Container(
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: SalonGlittColors.cardBorder),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 48,
                  color: SalonGlittColors.textMuted,
                ),
                const SizedBox(height: 14),
                const Text(
                  'No tienes citas programadas actualmente',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: SalonGlittColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Explora nuestros servicios y agenda tu próxima sesión en SalonGlitt.',
                  style: TextStyle(
                    color: SalonGlittColors.textMuted,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: () => setState(() => _currentTabIndex = 1),
                  style: FilledButton.styleFrom(
                    backgroundColor: SalonGlittColors.royalPurple,
                  ),
                  child: const Text('Agendar mi primer servicio'),
                ),
              ],
            ),
          )
        else
          Column(
            children: _userAppointments.map((cita) {
              final isConfirmed = cita['estado'] == 'Confirmada';
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: SalonGlittColors.cardBorder),
                  boxShadow: [
                    BoxShadow(
                      color: SalonGlittColors.deepPurple.withValues(
                        alpha: 0.03,
                      ),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: SalonGlittColors.softPink,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.calendar_month_rounded,
                        color: SalonGlittColors.royalPurple,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: isConfirmed
                                      ? SalonGlittColors.successBg
                                      : SalonGlittColors.softPink,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  cita['estado'].toString(),
                                  style: TextStyle(
                                    color: isConfirmed
                                        ? SalonGlittColors.successGreen
                                        : SalonGlittColors.royalPurple,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${cita['fecha']} · ${cita['hora']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: SalonGlittColors.textDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            cita['servicio'].toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: SalonGlittColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cita['profesional'].toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: SalonGlittColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Cancelar cita',
                      onPressed: () {
                        setState(() {
                          _userAppointments.remove(cita);
                        });
                        _showMessage('Cita cancelada.');
                      },
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.black38,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  // -------------------------------------------------------------
  // PESTAÑA 3: PERFIL DE USUARIO (Diseño boutique de lujo y completo)
  // -------------------------------------------------------------
  void _openEditProfileModal() {
    final user =
        _localUserProfile ??
        _apiService.currentUser ??
        const <String, dynamic>{};
    final currentName = user['nombreuser']?.toString() ?? '';
    final currentPhone = user['telefono']?.toString() ?? '';

    final nameController = TextEditingController(text: currentName);
    final phoneController = TextEditingController(text: currentPhone);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(28, 20, 28, 32),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Icon(
                      Icons.manage_accounts_rounded,
                      color: SalonGlittColors.royalPurple,
                      size: 26,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Editar Información Personal',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: SalonGlittColors.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Actualiza los datos de tu cuenta en SalonGlitt.',
                  style: TextStyle(
                    color: SalonGlittColors.textMuted,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: _inputDecoration(
                    label: 'Nombre completo',
                    icon: Icons.person_outline,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecoration(
                    label: 'Teléfono de contacto',
                    icon: Icons.phone_outlined,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    final newName = nameController.text.trim();
                    final newPhone = phoneController.text.trim();
                    if (newName.isEmpty) {
                      _showMessage(
                        'El nombre no puede estar vacío.',
                        isError: true,
                      );
                      return;
                    }
                    setState(() {
                      _localUserProfile = {
                        ...user,
                        'nombreuser': newName,
                        'telefono': newPhone,
                      };
                    });
                    Navigator.pop(ctx);
                    _showMessage('¡Perfil actualizado con éxito! ✨');
                  },
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Guardar Cambios'),
                  style: FilledButton.styleFrom(
                    backgroundColor: SalonGlittColors.royalPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: SalonGlittColors.hotPink),
            SizedBox(width: 10),
            Text(
              'Cerrar Sesión',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          '¿Estás segura de que deseas salir de tu cuenta de SalonGlitt?',
          style: TextStyle(color: SalonGlittColors.textMuted, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _handleLogout();
            },
            style: FilledButton.styleFrom(
              backgroundColor: SalonGlittColors.hotPink,
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  void _openPhotoOptionsSheet() {
    final user =
        _localUserProfile ??
        _apiService.currentUser ??
        const <String, dynamic>{};
    final name = user['nombreuser']?.toString() ?? 'Cliente';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 30),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Cambiar foto de perfil',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: SalonGlittColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Sube una imagen desde tu dispositivo o elige un avatar.',
                style: TextStyle(
                  color: SalonGlittColors.textMuted,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: AnimatedAvatar(
                  radius: 40,
                  initial: name.isEmpty ? 'S' : name[0].toUpperCase(),
                  photoUrl: _resolvePhotoUrl(_profilePhotoUrl),
                  photoBytes: _profilePhotoBytes,
                  emoji: _avatarEmoji,
                  fontSize: 32,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _pickProfilePhotoFromDevice();
                },
                icon: const Icon(Icons.upload_rounded),
                label: const Text('Subir imagen desde mi dispositivo'),
                style: FilledButton.styleFrom(
                  backgroundColor: SalonGlittColors.royalPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Elige un avatar',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: SalonGlittColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 14,
                runSpacing: 14,
                alignment: WrapAlignment.center,
                children: _avatarOptions.map((option) {
                  final selected =
                      _profilePhotoBytes == null &&
                      ((option.isEmoji && _avatarEmoji == option.emoji) ||
                          (!option.isEmoji &&
                              _avatarEmoji.isEmpty &&
                              _profilePhotoUrl == option.imageUrl));
                  return InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      setState(() {
                        if (option.isEmoji) {
                          _avatarEmoji = option.emoji!;
                          _profilePhotoUrl = '';
                        } else {
                          _profilePhotoUrl = option.imageUrl!;
                          _avatarEmoji = '';
                        }
                        _profilePhotoBytes = null;
                      });
                      Navigator.pop(ctx);
                      _showMessage('Avatar actualizado ✨');
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected
                                  ? SalonGlittColors.royalPurple
                                  : SalonGlittColors.cardBorder,
                              width: selected ? 2.2 : 1.5,
                            ),
                          ),
                          child: AnimatedAvatar(
                            radius: 26,
                            initial: option.label[0],
                            photoUrl: option.imageUrl ?? '',
                            emoji: option.emoji ?? '',
                            backgroundColor: option.bgColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          option.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? SalonGlittColors.royalPurple
                                : SalonGlittColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickProfilePhotoFromDevice() async {
    try {
      final file = await FilePicker.pickFile(type: FileType.image);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        _showMessage('No se pudo leer la imagen seleccionada.', isError: true);
        return;
      }
      if (!mounted) return;
      setState(() {
        _profilePhotoBytes = bytes;
        _avatarEmoji = '';
      });

      try {
        await _apiService.uploadProfilePhoto(
          bytes,
          fileName: file.name,
          mimeType: _mimeTypeFor(file.name),
        );
        if (!mounted) return;
        final saved = _apiService.currentUser;
        final savedUrl =
            saved?['foto_url'] ??
            saved?['foto'] ??
            saved?['avatar_url'] ??
            saved?['foto_perfil'];
        if (savedUrl is String && savedUrl.isNotEmpty) {
          setState(() {
            _profilePhotoUrl = _resolvePhotoUrl(savedUrl);
            _profilePhotoBytes = null;
            _avatarEmoji = '';
          });
        }
        _showMessage('Foto de perfil actualizada ✨');
      } catch (error) {
        if (!mounted) return;
        _showMessage(
          'Vista previa aplicada. El servidor aún no guarda la foto: $error',
          isError: true,
        );
      }
    } catch (error) {
      _showMessage(
        'No se pudo abrir el selector de imágenes: $error',
        isError: true,
      );
    }
  }

  String _resolvePhotoUrl(String url) {
    if (url.isEmpty) return url;
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    return '${ApiConfig.baseUrl}${url.startsWith('/') ? '' : '/'}$url';
  }

  String _mimeTypeFor(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    const known = <String, String>{
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'webp': 'image/webp',
      'bmp': 'image/bmp',
    };
    return known[ext] ?? 'image/png';
  }

  Widget _buildProfileTab(bool isWide) {
    final user =
        _localUserProfile ??
        _apiService.currentUser ??
        const <String, dynamic>{};
    final name = user['nombreuser']?.toString() ?? 'Cliente';
    final email = user['email']?.toString() ?? 'Sin correo registrado';
    final phone = user['telefono']?.toString() ?? '';
    final role = user['rol']?.toString() ?? 'cliente';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Tarjeta Portada y Avatar Flotante con estilo Salón de Lujo
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: SalonGlittColors.cardBorder),
            boxShadow: [
              BoxShadow(
                color: SalonGlittColors.deepPurple.withValues(alpha: 0.05),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Banner de portada
              Container(
                height: 120,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      SalonGlittColors.deepPurple,
                      SalonGlittColors.royalPurple,
                      Color(0xFFB57D9D),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                ),
                padding: const EdgeInsets.all(18),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: SalonGlittColors.lightGold,
                      size: 26,
                    ),
                  ],
                ),
              ),

              // Contenido con Avatar flotante, Nombre y Acciones
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 26),
                child: Column(
                  children: [
                    Transform.translate(
                      offset: const Offset(0, -42),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Avatar con borde dorado
                          Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 14,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: AnimatedAvatar(
                                  radius: 42,
                                  initial: name.isEmpty
                                      ? 'S'
                                      : name[0].toUpperCase(),
                                  photoUrl: _resolvePhotoUrl(_profilePhotoUrl),
                                  photoBytes: _profilePhotoBytes,
                                  emoji: _avatarEmoji,
                                  fontSize: 34,
                                ),
                              ),
                              Positioned(
                                right: 2,
                                bottom: 2,
                                child: InkWell(
                                  onTap: _openPhotoOptionsSheet,
                                  customBorder: const CircleBorder(),
                                  child: Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: SalonGlittColors.royalPurple,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.15,
                                          ),
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_rounded,
                                      size: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        name,
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w800,
                                          color: SalonGlittColors.textDark,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.verified_rounded,
                                      color: SalonGlittColors.metallicGold,
                                      size: 22,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  email,
                                  style: const TextStyle(
                                    color: SalonGlittColors.textMuted,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isWide) ...[
                            OutlinedButton.icon(
                              onPressed: _openEditProfileModal,
                              icon: const Icon(Icons.edit_outlined, size: 16),
                              label: const Text('Editar Perfil'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: SalonGlittColors.royalPurple,
                                side: const BorderSide(
                                  color: SalonGlittColors.cardBorder,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            OutlinedButton.icon(
                              onPressed: _confirmLogoutDialog,
                              icon: const Icon(Icons.logout_rounded, size: 16),
                              label: const Text('Cerrar Sesión'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: SalonGlittColors.hotPink,
                                side: const BorderSide(
                                  color: Color(0xFFFFD4DF),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    if (!isWide) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _openEditProfileModal,
                              icon: const Icon(Icons.edit_outlined, size: 16),
                              label: const Text('Editar Perfil'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: SalonGlittColors.royalPurple,
                                side: const BorderSide(
                                  color: SalonGlittColors.cardBorder,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton.icon(
                            onPressed: _confirmLogoutDialog,
                            icon: const Icon(Icons.logout_rounded, size: 16),
                            label: const Text('Salir'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: SalonGlittColors.hotPink,
                              side: const BorderSide(color: Color(0xFFFFD4DF)),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Badges de membresía y rol
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: SalonGlittColors.champagne,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: SalonGlittColors.metallicGold.withValues(
                                alpha: 0.4,
                              ),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.workspace_premium_rounded,
                                size: 15,
                                color: SalonGlittColors.metallicGold,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Miembro Glitt VIP · Nivel Oro',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: SalonGlittColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: SalonGlittColors.softPink,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: SalonGlittColors.pastelRose.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                          child: Text(
                            'Rol: $role',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: SalonGlittColors.hotPink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 2. Fila de Métricas / Club Glitt Rewards
        LayoutBuilder(
          builder: (context, box) {
            final cardWidth = isWide
                ? (box.maxWidth - 48) / 4
                : (box.maxWidth - 14) / 2;
            return Wrap(
              spacing: 16,
              runSpacing: 14,
              children: [
                _buildProfileMetricCard(
                  width: cardWidth,
                  icon: Icons.calendar_today_rounded,
                  iconColor: SalonGlittColors.royalPurple,
                  title: 'Citas Activas',
                  value: '${_userAppointments.length}',
                  subtitle: 'Programadas',
                ),
                _buildProfileMetricCard(
                  width: cardWidth,
                  icon: Icons.stars_rounded,
                  iconColor: SalonGlittColors.metallicGold,
                  title: 'Puntos Glitt',
                  value: '380 pts',
                  subtitle: 'Canjeables en spa',
                ),
                _buildProfileMetricCard(
                  width: cardWidth,
                  icon: Icons.diamond_outlined,
                  iconColor: SalonGlittColors.hotPink,
                  title: 'Nivel Cliente',
                  value: 'Oro VIP',
                  subtitle: '10% dcto en citas',
                ),
                _buildProfileMetricCard(
                  width: cardWidth,
                  icon: Icons.local_offer_outlined,
                  iconColor: SalonGlittColors.successGreen,
                  title: 'Cupón Activo',
                  value: 'GLITT15',
                  subtitle: '15% de regalo',
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 22),

        // 3. Bloques de Información Personal y Preferencias del Salón
        if (isWide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: _buildPersonalInfoBlock(name, email, phone, role),
              ),
              const SizedBox(width: 20),
              Expanded(flex: 5, child: _buildSalonPreferencesBlock()),
            ],
          )
        else ...[
          _buildPersonalInfoBlock(name, email, phone, role),
          const SizedBox(height: 18),
          _buildSalonPreferencesBlock(),
        ],

        const SizedBox(height: 22),

        // 4. Barra de Acciones de Cuenta y Seguridad
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: SalonGlittColors.cardBorder),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: SalonGlittColors.successBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: SalonGlittColors.successGreen,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sesión Segura y Cifrada',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: SalonGlittColors.textDark,
                      ),
                    ),
                    Text(
                      'Tus datos y reservas están protegidos con token de autenticación.',
                      style: TextStyle(
                        fontSize: 12,
                        color: SalonGlittColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () => setState(() => _currentTabIndex = 1),
                icon: const Icon(Icons.spa_rounded, size: 16),
                label: const Text('Ver servicios'),
                style: FilledButton.styleFrom(
                  backgroundColor: SalonGlittColors.royalPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileMetricCard({
    required double width,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SalonGlittColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: SalonGlittColors.deepPurple.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: SalonGlittColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: SalonGlittColors.textMuted,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: Colors.black38),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoBlock(
    String name,
    String email,
    String phone,
    String role,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: SalonGlittColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: SalonGlittColors.deepPurple.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.person_outline_rounded,
                    color: SalonGlittColors.royalPurple,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Información de la Cuenta',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: SalonGlittColors.textDark,
                    ),
                  ),
                ],
              ),
              IconButton(
                tooltip: 'Editar datos',
                onPressed: _openEditProfileModal,
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: SalonGlittColors.royalPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.badge_outlined, 'Nombre completo', name),
          const Divider(height: 20, color: SalonGlittColors.cardBorder),
          _buildInfoRow(
            Icons.alternate_email_rounded,
            'Correo electrónico',
            email,
            badge: 'Verificado',
          ),
          const Divider(height: 20, color: SalonGlittColors.cardBorder),
          _buildInfoRow(
            Icons.phone_outlined,
            'Teléfono móvil',
            phone.isNotEmpty ? phone : 'No registrado',
          ),
          const Divider(height: 20, color: SalonGlittColors.cardBorder),
          _buildInfoRow(Icons.security_outlined, 'Rol asignado', 'Rol: $role'),
          const Divider(height: 20, color: SalonGlittColors.cardBorder),
          _buildInfoRow(
            Icons.calendar_month_outlined,
            'Miembro desde',
            'Octubre 2024',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    String? badge,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: SalonGlittColors.royalPurple),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: SalonGlittColors.textMuted,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: SalonGlittColors.textDark,
              ),
            ),
          ],
        ),
        if (badge != null) ...[
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: SalonGlittColors.successBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              badge,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: SalonGlittColors.successGreen,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSalonPreferencesBlock() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: SalonGlittColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: SalonGlittColors.deepPurple.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.spa_outlined,
                color: SalonGlittColors.royalPurple,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Preferencias de Belleza & Salón',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: SalonGlittColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Estilista preferida
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: SalonGlittColors.softLavender,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white,
                  child: Text(
                    'C',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: SalonGlittColors.royalPurple,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Especialista Favorita',
                        style: TextStyle(
                          fontSize: 11,
                          color: SalonGlittColors.textMuted,
                        ),
                      ),
                      Text(
                        'Camila R. · Especialista en Uñas',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: SalonGlittColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Notificaciones de Citas
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeThumbColor: SalonGlittColors.royalPurple,
            title: const Text(
              'Recordatorios de Citas',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: SalonGlittColors.textDark,
              ),
            ),
            subtitle: const Text(
              'Avisos por WhatsApp antes de tu visita',
              style: TextStyle(fontSize: 11, color: SalonGlittColors.textMuted),
            ),
            value: _whatsappNotifications,
            onChanged: (val) {
              setState(() => _whatsappNotifications = val);
              _showMessage(
                val ? 'Recordatorios activados' : 'Recordatorios desactivados',
              );
            },
          ),

          const Divider(height: 10, color: SalonGlittColors.cardBorder),

          // Promociones y Descuentos
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeThumbColor: SalonGlittColors.royalPurple,
            title: const Text(
              'Promociones y Descuentos VIP',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: SalonGlittColors.textDark,
              ),
            ),
            subtitle: const Text(
              'Recibe beneficios exclusivos del club de belleza',
              style: TextStyle(fontSize: 11, color: SalonGlittColors.textMuted),
            ),
            value: _emailPromos,
            onChanged: (val) {
              setState(() => _emailPromos = val);
              _showMessage(
                val ? 'Promociones activadas' : 'Promociones desactivadas',
              );
            },
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // VISTA NO AUTENTICADA: LOGIN Y REGISTRO (Mantiene compatibilidad con tests)
  // -------------------------------------------------------------
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
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: SalonGlittColors.cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: SalonGlittColors.cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: SalonGlittColors.royalPurple,
          width: 1.6,
        ),
      ),
    );
  }

  Widget _buildWelcomeHeroUnauth() {
    return Container(
      constraints: const BoxConstraints(minHeight: 400),
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            SalonGlittColors.deepPurple,
            SalonGlittColors.royalPurple,
            Color(0xFFB57D9D),
          ],
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
            right: 0,
            top: 0,
            child: Icon(
              Icons.auto_awesome,
              color: SalonGlittColors.lightGold,
              size: 36,
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
                  size: 32,
                ),
              ),
              const SizedBox(height: 60),
              Text(
                _isRegisterMode
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
                _isRegisterMode
                    ? 'Únete a SalonGlitt y reserva tus servicios de belleza con atención exclusiva.'
                    : 'Accede a tus servicios y descubre una experiencia de belleza hecha a tu medida.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.84),
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAuthPanel() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: SalonGlittColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: SalonGlittColors.deepPurple.withValues(alpha: 0.06),
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
              color: SalonGlittColors.textDark,
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            _isRegisterMode
                ? 'Completa tus datos para unirte a SalonGlitt.'
                : 'Inicia sesión para continuar con tu experiencia.',
            style: const TextStyle(
              color: SalonGlittColors.textMuted,
              height: 1.4,
            ),
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
                  borderRadius: BorderRadius.circular(16),
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

  // -------------------------------------------------------------
  // MÉTODO BUILD PRINCIPAL
  // -------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final isAuthenticated = _apiService.isAuthenticated;
    final userName =
        (_localUserProfile ?? _apiService.currentUser)?['nombreuser']
            ?.toString() ??
        'Cliente';

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFCF9FC), SalonGlittColors.lightBlush],
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
                  constraints: const BoxConstraints(maxWidth: 1140),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWide ? 32 : 18,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Barra superior
                        _buildTopNavBar(isWide),

                        // Barra de navegación móvil (si está autenticado y en pantalla pequeña)
                        if (!isWide && isAuthenticated) _buildMobileTabNav(),

                        const SizedBox(height: 24),

                        // Contenido dinámico según estado de autenticación y pestaña
                        if (isAuthenticated) ...[
                          if (_currentTabIndex == 0)
                            _buildHomeTab(isWide, userName)
                          else if (_currentTabIndex == 1)
                            _buildServicesTab(isWide)
                          else if (_currentTabIndex == 2)
                            _buildAppointmentsTab(isWide)
                          else if (_currentTabIndex == 3)
                            _buildProfileTab(isWide),
                        ] else ...[
                          // Vista no autenticada (Login / Register)
                          if (isWide)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: _buildWelcomeHeroUnauth(),
                                ),
                                const SizedBox(width: 24),
                                Expanded(flex: 6, child: _buildAuthPanel()),
                              ],
                            )
                          else ...[
                            _buildWelcomeHeroUnauth(),
                            const SizedBox(height: 18),
                            _buildAuthPanel(),
                          ],
                        ],

                        const SizedBox(height: 28),

                        // Pie de página sutil
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'SalonGlitt · Cuidado con estilo',
                              style: TextStyle(
                                color: SalonGlittColors.textMuted.withValues(
                                  alpha: 0.65,
                                ),
                                fontSize: 12,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: _showServerStatusDialog,
                              child: Text(
                                '· Info API',
                                style: TextStyle(
                                  color: SalonGlittColors.royalPurple
                                      .withValues(alpha: 0.65),
                                  fontSize: 12,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
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
