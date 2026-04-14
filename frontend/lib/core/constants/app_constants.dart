class AppConstants {
  // App Info
  static const String appName = 'Chest X-Ray ML';

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

  // Asset Paths (Placeholders)
  static const String logoPath = 'assets/icons/logo.png';

  // Const app Strings
  static const String homeTitle = 'ML-Powered\nX-Ray Analysis';
  static const String homeSubtitle =
      'Educational ML tool for classifying chest X-rays into Normal, Tuberculosis, Pneumonia, or Unknown.';
  static const String homeWarning =
      'Note: predictions don\'t determine real world outcome';
  static const String permissionErrorTitle = 'Permissions Required';
  static const String permissionErrorSubtitle =
      'This app requires camera and storage access to provide medical analysis.';

  // Analysis strings
  static const String analysisTitle = 'Diagnostic Preview';
  static const String analysisComplete = 'Analysis complete.';
  static const String analysisScanning = 'AI is scanning the X-Ray...';
  static const String analysisReady =
      'Ready for processing. Tap analyze to begin.';
}
