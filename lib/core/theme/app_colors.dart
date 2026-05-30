import 'package:flutter/material.dart';

/// Radar / cockpit palette. The single source of truth for color in the app —
/// widgets must read from here (via [AppTheme]) and never hardcode colors.
abstract final class AppColors {
  const AppColors._();

  // Surfaces
  static const Color background = Color(0xFF0A0E14);
  static const Color surface = Color(0xFF121A24);
  static const Color surfaceVariant = Color(0xFF1B2735);
  static const Color outline = Color(0xFF243240);

  // Accents
  static const Color primary = Color(0xFF22D3EE); // turquoise radar
  static const Color primaryDim = Color(0xFF0E7490);
  static const Color accent = Color(0xFF7C5CFF);

  // Text
  static const Color onSurface = Color(0xFFE6EDF3);
  static const Color onSurfaceMuted = Color(0xFF8696A7);
  static const Color onPrimary = Color(0xFF03212B);

  // Semantic
  static const Color success = Color(0xFF34D399); // airborne / positive
  static const Color warning = Color(0xFFFBBF24); // mock data / caution
  static const Color error = Color(0xFFF87171);

  // Gradient for hero / radar backdrops
  static const List<Color> radarGradient = [
    Color(0xFF0A0E14),
    Color(0xFF0E1B24),
    Color(0xFF0B2530),
  ];
}
