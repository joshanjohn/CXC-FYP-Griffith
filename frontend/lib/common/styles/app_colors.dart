import 'package:flutter/material.dart';

class AppColors {

  static const Color primary = Color(0xFF00B4D8); 
  static const Color primaryDark = Color(0xFF0077B6);
  static const Color accent = Color(0xFF48CAE4);

  // Neutral Colors Light
  static const Color backgroundLight = Color(
    0xFFF0F9FF,
  ); // Very light blue tint
  static const Color surfaceLight = Colors.white;
  static const Color onSurfaceLight = Color(0xFF1E293B);
  static const Color outlineLight = Color(0xFFE2E8F0);

  // Neutral Colors - dark 
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color onSurfaceDark = Color(0xFFF8FAFC);
  static const Color outlineDark = Color(0xFF334155);

  // Solid Simple Shades
  static const Color glassWhite = Colors.white;
  static const Color glassOutline = Color(0xFFF1F5F9);

  // Semantic Colors
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF00B4D8);

  // Solid Colors
  static const List<Color> primaryGradient = [
    Color(0xFF00B4D8),
    Color(0xFF00B4D8),
  ];
  static const List<Color> backgroundGradient = [
    Color(0xFFFFFFFF),
    Color(0xFFFFFFFF),
  ];
}
