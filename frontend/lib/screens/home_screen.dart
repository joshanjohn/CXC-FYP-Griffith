import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/image_service.dart';
import '../utils/responsive_helper.dart';
import 'image_preview_screen.dart';

/// Enum to track the current loading state of individual actions
enum HomeActionState { none, uploading, capturing }

/// Home screen with upload and camera capture options
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ImageService _imageService = ImageService();
  HomeActionState _activeAction = HomeActionState.none;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeService();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
    _fadeController.forward();
  }

  Future<void> _initializeService() async {
    await _imageService.initializeCameras();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _handleImageSelection({required bool fromCamera}) async {
    setState(
      () => _activeAction = fromCamera
          ? HomeActionState.capturing
          : HomeActionState.uploading,
    );

    try {
      final result = await _imageService.selectImage(fromCamera: fromCamera);

      if (result != null && mounted) {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ImagePreviewScreen(
                  imageSource: result is XFile
                      ? File(result.path)
                      : File(result),
                ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final message = e.toString().contains('Permission denied')
            ? 'Permission is required to access the ${fromCamera ? 'camera' : 'gallery'}. Please enable it in settings.'
            : 'Error selecting image: $e';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            action: e.toString().contains('Permission denied')
                ? SnackBarAction(
                    label: 'Settings',
                    textColor: Colors.white,
                    onPressed: () => openAppSettings(),
                  )
                : null,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _activeAction = HomeActionState.none);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isMobile = ResponsiveHelper.isMobile(context);
    final isWide = !isMobile;
    final isPlatformMobile = ResponsiveHelper.isPlatformMobile();

    return Scaffold(
      body: Stack(
        children: [
          // Subtle Background Pattern
          Positioned.fill(
            child: CustomPaint(
              painter: MedicalBackgroundPainter(
                color: colorScheme.primary.withOpacity(0.04),
                isDarkMode: theme.brightness == Brightness.dark,
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: SingleChildScrollView(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: ResponsiveHelper.getMaxContentWidth(context),
                    ),
                    padding: ResponsiveHelper.getResponsivePadding(context),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // App Icon/Logo
                        _buildAnimatedLogo(colorScheme, isMobile),

                        SizedBox(height: isMobile ? 32 : 48),

                        // Title
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              colorScheme.primary,
                              colorScheme.secondary,
                            ],
                          ).createShader(bounds),
                          child: Text(
                            'Chest X-Ray Analysis',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context,
                                38,
                              ),
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.5,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        SizedBox(height: isMobile ? 12 : 16),

                        // Subtitle
                        Text(
                          'Advanced artificial intelligence for medical diagnostic imaging',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              18,
                            ),
                            color: colorScheme.onSurface.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: isMobile ? 48 : 72),

                        // Upload/Capture Options (Optimized for Screen Width)
                        if (isWide && isPlatformMobile)
                          Row(
                            children: [
                              Expanded(
                                child: _buildPrimaryActionCard(
                                  context: context,
                                  icon: Icons.upload_file_rounded,
                                  title: 'Gallery Upload',
                                  description: 'Import from device storage',
                                  onTap: () =>
                                      _handleImageSelection(fromCamera: false),
                                  isLoading:
                                      _activeAction ==
                                      HomeActionState.uploading,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: _buildPrimaryActionCard(
                                  context: context,
                                  icon: Icons.camera_enhance_rounded,
                                  title: 'Live Capture',
                                  description: 'Capture via device camera',
                                  onTap: () =>
                                      _handleImageSelection(fromCamera: true),
                                  isLoading:
                                      _activeAction ==
                                      HomeActionState.capturing,
                                  color: colorScheme.secondary,
                                ),
                              ),
                            ],
                          )
                        else
                          Column(
                            children: [
                              _buildPrimaryActionCard(
                                context: context,
                                icon: Icons.upload_file_rounded,
                                title: 'Upload X-Ray',
                                description: 'Select an image from gallery',
                                onTap: () =>
                                    _handleImageSelection(fromCamera: false),
                                isLoading:
                                    _activeAction == HomeActionState.uploading,
                                color: colorScheme.primary,
                              ),
                              if (isPlatformMobile) ...[
                                const SizedBox(height: 20),
                                _buildPrimaryActionCard(
                                  context: context,
                                  icon: Icons.camera_alt_rounded,
                                  title: 'Capture X-Ray',
                                  description: 'Take a new photo with camera',
                                  onTap: () =>
                                      _handleImageSelection(fromCamera: true),
                                  isLoading:
                                      _activeAction ==
                                      HomeActionState.capturing,
                                  color: colorScheme.secondary,
                                ),
                              ],
                            ],
                          ),

                        SizedBox(height: isMobile ? 48 : 64),

                        // Refined Info footer
                        _buildInfoFooter(theme, colorScheme),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedLogo(ColorScheme colorScheme, bool isMobile) {
    return Container(
      width: isMobile ? 120 : 140,
      height: isMobile ? 120 : 140,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.15),
            blurRadius: 40,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: isMobile ? 100 : 120,
          height: isMobile ? 100 : 120,
          decoration: BoxDecoration(
            gradient: SweepGradient(
              colors: [
                colorScheme.primary,
                colorScheme.secondary,
                colorScheme.primary,
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.health_and_safety_rounded,
                size: isMobile ? 60 : 72,
                color: colorScheme.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
    required bool isLoading,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isMobile = ResponsiveHelper.isMobile(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _activeAction != HomeActionState.none ? null : onTap,
        child: AnimatedScale(
          scale: _activeAction == HomeActionState.none
              ? 1.0
              : (_activeAction != HomeActionState.none && !isLoading
                    ? 0.98
                    : 1.0),
          duration: const Duration(milliseconds: 200),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 24 : 32),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: color.withOpacity(0.15), width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        size: isMobile ? 28 : 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          22,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          15,
                        ),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (isLoading)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  )
                else
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.add_rounded, color: color, size: 20),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoFooter(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 24,
        runSpacing: 12,
        children: [
          _buildInfoItem(
            Icons.security_rounded,
            'HIPAA Compliant',
            Colors.blue,
          ),
          _buildInfoItem(
            Icons.auto_awesome_rounded,
            'AI-Powered',
            Colors.amber,
          ),
          _buildInfoItem(Icons.speed_rounded, 'Rapid Results', Colors.green),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: Colors.black.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

/// Custom painter for a medical-themed grid/dots background
class MedicalBackgroundPainter extends CustomPainter {
  final Color color;
  final bool isDarkMode;

  MedicalBackgroundPainter({required this.color, required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;

    const spacing = 50.0;

    // Draw grid of small dots
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }

    // Draw some larger decorative circles
    final largeCirclePaint = Paint()
      ..color = color.withOpacity(0.06)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.15),
      180,
      largeCirclePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.85),
      240,
      largeCirclePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
