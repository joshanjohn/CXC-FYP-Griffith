class AppConstants {
  // App Info
  static const String appName = 'Chest X-Ray AI';

  // Responsive Design
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1200.0;
  static const double maxContentWidth = 1200.0;

  // Animation Durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration slowAnimation = Duration(milliseconds: 1000);

  // Padding & Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingExtraLarge = 32.0;

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;
  static const double radiusExtraLarge = 32.0;

  // Asset Paths (Placeholders for now)
  static const String logoPath = 'assets/icons/logo.png';

  // Strings
  static const String homeTitle = 'AI-Powered\nX-Ray Analysis';
  static const String homeSubtitle =
      'Advanced diagnostic imaging with state-of-the-art neural networks.';
  static const String permissionErrorTitle = 'Permissions Required';
  static const String permissionErrorSubtitle =
      'This app requires camera and storage access to provide medical analysis.';
}
