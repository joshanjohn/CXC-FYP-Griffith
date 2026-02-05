import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../data/datasources/remote/image_datasource.dart';
import '../../../../shared/responsive/responsive_helper.dart';
import '../../../../app/themes/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../analysis/presentation/pages/image_preview_page.dart';
import '../../../analysis/presentation/pages/permission_error_page.dart';
import '../../../analysis/presentation/widgets/drag_drop_zone.dart';
import '../../../../shared/widgets/background_painter.dart';

/// Enum to track the current loading state of individual actions
enum HomeActionState { none, uploading, capturing }

/// Home screen with upload and camera capture options
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final ImageDatasource _imageService = ImageDatasource();
  HomeActionState _activeAction = HomeActionState.none;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeService();

    _fadeController = AnimationController(
      duration: AppConstants.slowAnimation,
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
        final dynamic source;
        if (kIsWeb) {
          source = result as Uint8List;
        } else if (result is XFile) {
          source = File(result.path);
        } else if (result is String) {
          source = File(result);
        } else {
          source = result;
        }

        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ImagePreviewPage(imageSource: source),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: AppConstants.mediumAnimation,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final errorString = e.toString();

        if (errorString.contains('PERMISSION_PERMANENTLY_DENIED') ||
            errorString.contains('PERMISSION_DENIED')) {
          // Strictly redirect to error screen as requested
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PermissionErrorPage(
                permissionName: fromCamera ? 'Camera' : 'Storage/Photos',
                description: fromCamera
                    ? 'The app cannot capture X-rays without camera access.'
                    : 'The app cannot upload X-rays without storage access.',
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _activeAction = HomeActionState.none);
      }
    }
  }

  Future<void> _handleFileDrop(List<dynamic> droppedFiles) async {
    if (droppedFiles.isEmpty) return;

    final file = droppedFiles.first;
    dynamic source;

    if (kIsWeb) {
      // In desktop_drop on web, 'file' is a CrossFile (XFile)
      // but we need to fetch bytes explicitly
      final bytes = await file.readAsBytes();
      source = bytes as Uint8List;
    } else {
      source = File(file.path);
    }

    if (mounted) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              ImagePreviewPage(imageSource: source),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: AppConstants.mediumAnimation,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    final isWide = !isMobile;
    final isPlatformMobile = ResponsiveHelper.isPlatformMobile();

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: DragDropZone(
        onFilesDropped: _handleFileDrop,
        child: Stack(
          children: [
            // Subtle Background Pattern
            Positioned.fill(
              child: CustomPaint(
                painter: MedicalBackgroundPainter(
                  color: AppColors.primary.withOpacity(0.04),
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
                      constraints: const BoxConstraints(
                        maxWidth: AppConstants.maxContentWidth,
                      ),
                      padding: ResponsiveHelper.getResponsivePadding(context),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // App Icon/Logo
                          _buildAnimatedLogo(isMobile),

                          const SizedBox(
                            height: AppConstants.paddingExtraLarge,
                          ),

                          // Title
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: AppColors.primaryGradient,
                            ).createShader(bounds),
                            child: Text(
                              AppConstants.homeTitle,
                              style: theme.textTheme.headlineLarge?.copyWith(
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(
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

                          const SizedBox(height: AppConstants.paddingMedium),

                          // Subtitle
                          Text(
                            AppConstants.homeSubtitle,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context,
                                18,
                              ),
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.7,
                              ),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 72),

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
                                    onTap: () => _handleImageSelection(
                                      fromCamera: false,
                                    ),
                                    isLoading:
                                        _activeAction ==
                                        HomeActionState.uploading,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(
                                  width: AppConstants.paddingLarge,
                                ),
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
                                    color: AppColors.secondary,
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
                                      _activeAction ==
                                      HomeActionState.uploading,
                                  color: AppColors.primary,
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
                                    color: AppColors.secondary,
                                  ),
                                ],
                              ],
                            ),

                          const SizedBox(height: 64),

                          // Refined Info footer
                          _buildInfoFooter(theme),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo(bool isMobile) {
    return Container(
      width: isMobile ? 120 : 140,
      height: isMobile ? 120 : 140,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 40,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: isMobile ? 100 : 120,
          height: isMobile ? 100 : 120,
          decoration: const BoxDecoration(
            gradient: SweepGradient(
              colors: [
                AppColors.primary,
                AppColors.secondary,
                AppColors.primary,
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.surfaceLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.health_and_safety_rounded,
                size: 60,
                color: AppColors.primary,
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
          duration: AppConstants.fastAnimation,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 24 : 32),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(
                AppConstants.radiusExtraLarge,
              ),
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

  Widget _buildInfoFooter(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
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
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ],
    );
  }
}
