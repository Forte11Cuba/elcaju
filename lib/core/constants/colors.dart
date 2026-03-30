import 'package:flutter/material.dart';

/// Paleta de colores de El Caju
/// Concepto: "Organic Digital / Tropical Privacy"
class AppColors {
  AppColors._();

  // === GRADIENT BACKGROUND ===
  // Degradado diagonal: púrpura profundo → naranja marañón
  static const Color deepVoidPurple = Color(0xFF1A0B2E);
  static const Color royalCashuPurple = Color(0xFF4A1259);
  static const Color maranonOrange = Color(0xFFE35D33);

  static const List<Color> backgroundGradient = [
    deepVoidPurple,
    royalCashuPurple,
    maranonOrange,
  ];

  static const List<double> backgroundGradientStops = [0.0, 0.6, 1.0];

  // === ACCENT COLORS ===
  static const Color primaryAction = Color(0xFFE35D33); // Naranja vibrante
  static const Color secondaryAction = Color(0xFFFFB74D); // Amarillo pulpa/Bitcoin
  static const Color bitcoinOrange = Color(0xFFF7931A); // Bitcoin brand orange
  static const Color success = Color(0xFF00E676); // Verde neón
  static const Color error = Color(0xFFFF5252); // Rojo suave
  static const Color warning = Color(0xFFFFB74D); // Amarillo

  // === BUTTON GRADIENT ===
  static const Color buttonGradientStart = Color(0xFFE35D33); // Naranja marañón
  static const Color buttonGradientEnd = Color(0xFFFF9100); // Ámbar

  static const List<Color> buttonGradient = [
    buttonGradientStart,
    buttonGradientEnd,
  ];

  // === TEXT COLORS ===
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFFFE0B2); // Blanco hueso/crema
  static Color textTertiary = Colors.white.withValues(alpha: 0.6);
  static Color textPlaceholder = Colors.white.withValues(alpha: 0.4);

  // === GLASS/CARD COLORS ===
  static const Color glassBase = Color(0xFFFFF3E0); // Base naranja muy pálida
  static const double glassOpacity = 0.05;
  static const double glassBorderOpacity = 0.1;

  // === TRANSACTION COLORS ===
  static const Color transactionReceived = success;
  static const Color transactionSent = maranonOrange;
  static const Color transactionPending = secondaryAction;
  static const Color transactionFailed = error;

  // === MINT STATUS ===
  static const Color mintConnected = success;
  static const Color mintDisconnected = error;
}
