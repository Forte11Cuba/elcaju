import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:cdk_flutter/cdk_flutter.dart' hide WalletProvider;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'providers/wallet_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/price_provider.dart';
import 'screens/1_splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar CDK Flutter (Cashu SDK)
  await CdkFlutter.init();

  // Configurar orientación y estilo de barra de estado
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF1A0B2E),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Inicializar PriceProvider
  final priceProvider = PriceProvider();
  priceProvider.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider.value(value: priceProvider),
      ],
      child: const ElCajuApp(),
    ),
  );
}

class ElCajuApp extends StatelessWidget {
  const ElCajuApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();

    return MaterialApp(
      title: 'ElCaju',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,

      // Localizaciones
      localizationsDelegates: const [
        L10n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es'), // Español (por defecto)
        Locale('en'), // English
        Locale('pt'), // Português
        Locale('fr'), // Français
        Locale('ru'), // Русский
        Locale('de'), // Deutsch
        Locale('it'), // Italiano
        Locale('ko'), // 한국어
        Locale('zh'), // 中文
        Locale('ja'), // 日本語
        Locale('sw'), // Kiswahili
      ],
      locale: Locale(settingsProvider.locale),

      home: const SplashScreen(),
    );
  }
}
