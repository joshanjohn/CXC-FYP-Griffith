import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color secondary = Color(0xFF8B5CF6); // Violet
  static const Color accent = Color(0xFFF43F5E); // Rose

  // Workspace Colors
  static const Color clientPrimary = Color(0xFF3B82F6);
  static const Color clientBackground = Color(0xFF1E3A8A);

  static const Color studioPrimary = Color(0xFFEF4444);
  static const Color studioBackground = Color(0xFF7F1D1D);

  static const Color coachPrimary = Color(0xFF10B981);
  static const Color coachBackground = Color(0xFF064E3B);

  // Neutral Colors (Light)
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Colors.white;
  static const Color onSurfaceLight = Color(0xFF0F172A);
  static const Color outlineLight = Color(0xFFE2E8F0);

  // Neutral Colors (Dark)
  static const Color backgroundDark = Color(0xFF030712);
  static const Color surfaceDark = Color(0xFF0F172A);
  static const Color onSurfaceDark = Color(0xFFF8FAFC);
  static const Color outlineDark = Color(0xFF1E293B);

  // Semantic Colors
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Gradient definitions
  static const List<Color> primaryGradient = [primary, secondary];
  static const List<Color> darkGradient = [
    Color(0xFF030712),
    Color(0xFF0F172A),
  ];
}
