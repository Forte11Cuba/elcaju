import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/gradient_background.dart';
import '../../providers/settings_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/p2pk_provider.dart';
import '../2_onboarding/welcome_screen.dart';
import '../3_home/home_screen.dart';

/// Splash Screen de El Caju
/// Inicializa los providers y redirige según el estado del wallet.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  String? _errorMessage;

  // Mensajes de carga aleatorios
  int _currentMessageIndex = 0;
  Timer? _messageTimer;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    // Iniciar rotación de mensajes de carga
    _currentMessageIndex = _random.nextInt(7);
    _messageTimer = Timer.periodic(const Duration(milliseconds: 800), (_) {
      if (mounted) {
        setState(() {
          _currentMessageIndex = _random.nextInt(7);
        });
      }
    });

    // Inicializar la app
    _initializeApp();
  }

  /// Obtiene el mensaje de carga actual basado en el índice
  String _getLoadingMessage(L10n? l10n) {
    if (l10n == null) return 'Cargando...';
    switch (_currentMessageIndex) {
      case 0: return l10n.loadingMessage1;
      case 1: return l10n.loadingMessage2;
      case 2: return l10n.loadingMessage3;
      case 3: return l10n.loadingMessage4;
      case 4: return l10n.loadingMessage5;
      case 5: return l10n.loadingMessage6;
      case 6: return l10n.loadingMessage7;
      default: return l10n.loadingMessage1;
    }
  }

  Future<void> _initializeApp() async {
    try {
      final settingsProvider = context.read<SettingsProvider>();
      final walletProvider = context.read<WalletProvider>();
      final p2pkProvider = context.read<P2PKProvider>();

      // Inicializar settings (cargar preferencias)
      await settingsProvider.initialize();

      // Esperar mínimo 2 segundos para mostrar splash
      await Future.delayed(const Duration(milliseconds: 2000));

      if (!mounted) return;

      // Verificar si ya existe un wallet
      if (settingsProvider.hasWallet) {
        // Cargar mnemonic e inicializar wallet
        final mnemonic = await settingsProvider.getMnemonic();

        if (mnemonic != null && mnemonic.isNotEmpty) {
          await walletProvider.initialize(mnemonic);

          // Inicializar P2PK (derivar clave principal del mnemonic)
          // Aislado: P2PK es secundario, su fallo no debe bloquear la wallet
          try {
            await p2pkProvider.initialize(mnemonic);
          } catch (e) {
            debugPrint('[SplashScreen] Error initializing P2PK (non-fatal): $e');
          }

          if (!mounted) return;

          // Restaurar mint y unidad activa desde settings
          await _restoreActiveState(settingsProvider, walletProvider);

          // Verificar proofs en background (no bloquea navegación)
          unawaited(_checkPendingTransactions(walletProvider));

          // Ir al Home
          _navigateTo(const HomeScreen());
        } else {
          // Error: hasWallet=true pero sin mnemonic
          // Esto no debería pasar, pero por si acaso
          _navigateTo(const WelcomeScreen());
        }
      } else {
        // No hay wallet, ir al onboarding
        _navigateTo(const WelcomeScreen());
      }
    } catch (e) {
      // Mostrar error pero permitir continuar al onboarding
      debugPrint('Error al inicializar: $e');
      setState(() {
        _errorMessage = e.toString();
      });

      // Esperar y continuar al onboarding
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        _navigateTo(const WelcomeScreen());
      }
    }
  }

  /// Restaura el mint y unidad activa desde SettingsProvider.
  Future<void> _restoreActiveState(
    SettingsProvider settings,
    WalletProvider wallet,
  ) async {
    try {
      // Restaurar mint activo si está guardado
      final savedMintUrl = settings.activeMintUrl;
      if (savedMintUrl != null && wallet.mintUrls.contains(savedMintUrl)) {
        await wallet.setActiveMint(savedMintUrl);
      }

      // Restaurar unidad activa si está guardada y es soportada
      final savedUnit = settings.activeUnit;
      if (wallet.activeUnits.contains(savedUnit)) {
        await wallet.setActiveUnit(savedUnit);
      }
    } catch (e) {
      debugPrint('Error restaurando estado activo: $e');
      // No bloquear si falla, usar defaults
    }
  }

  /// Verifica proofs pendientes en background.
  /// Se ejecuta sin bloquear la navegación.
  Future<void> _checkPendingTransactions(WalletProvider wallet) async {
    try {
      await wallet.checkPendingTransactions();
      debugPrint('Verificación de proofs completada');
    } catch (e) {
      debugPrint('Error verificando proofs: $e');
      // Silencioso - no mostrar error al usuario
    }
  }

  void _navigateTo(Widget screen) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Mascota / Logo
                  Image.asset(
                    'assets/img/elcajucubano.png',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: AppDimensions.paddingLarge),

                  // Nombre de la app
                  Text(
                    l10n?.appName ?? 'ElCaju',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingSmall),

                  // Mensaje de carga aleatorio
                  Text(
                    _getLoadingMessage(l10n),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingXLarge * 2),

                  // Loading indicator o mensaje de error
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppColors.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.secondaryAction.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
