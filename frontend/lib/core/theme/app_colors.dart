import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors
  static const Color primary = Color(0xFF007AFF);
  static const Color secondary = Color(0xFF5856D6);
  static const Color accent = Color(0xFF32ADE6);

  // Neutral Colors (Light)
  static const Color backgroundLight = Color(0xFFF2F2F7);
  static const Color surfaceLight = Colors.white;
  static const Color onSurfaceLight = Color(0xFF1C1C1E);
  static const Color outlineLight = Color(0xFFC7C7CC);

  // Neutral Colors (Dark)
  static const Color backgroundDark = Color(0xFF000000);
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color onSurfaceDark = Colors.white;
  static const Color outlineDark = Color(0xFF38383A);

  // Semantic Colors
  static const Color error = Color(0xFFFF3B30);
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);
  static const Color info = Color(0xFF007AFF);

  // Gradient definitions
  static const List<Color> primaryGradient = [primary, secondary];
  static const List<Color> surfaceGradient = [Colors.white, Color(0xFFF2F2F7)];
}
