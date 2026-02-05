import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../data/datasources/remote/image_datasource.dart';
import '../../../../app/themes/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/responsive/responsive_helper.dart';
import '../widgets/workspace_card.dart';
import '../../../../shared/widgets/background_painter.dart';
import '../widgets/drag_drop_zone.dart';
import '../../../../shared/widgets/adaptive_button.dart';
import 'image_preview_page.dart';
import 'permission_error_page.dart';

class WorkspacePage extends StatefulWidget {
  const WorkspacePage({super.key});

  @override
  State<WorkspacePage> createState() => _WorkspacePageState();
}

class _WorkspacePageState extends State<WorkspacePage> {
  final ImageDatasource _imageService = ImageDatasource();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _imageService.initializeCameras();
  }

  Future<void> _handleImageSelection({
    required bool fromCamera,
    dynamic dropFile,
  }) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      dynamic result;
      if (dropFile != null) {
        result = dropFile;
      } else {
        result = await _imageService.selectImage(fromCamera: fromCamera);
      }

      if (result != null && mounted) {
        final dynamic source;
        if (kIsWeb) {
          source = result is Uint8List
              ? result
              : await (result as dynamic).readAsBytes();
        } else if (result is String) {
          source = File(result);
        } else if (result is File) {
          source = result;
        } else {
          // Desktop drop file
          source = File((result as dynamic).path);
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
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF030712), const Color(0xFF0F172A)]
                      : [const Color(0xFFF8FAFC), const Color(0xFFF1F5F9)],
                ),
              ),
            ),
          ),

          // Decorative Shapes Painter
          Positioned.fill(
            child: CustomPaint(
              painter: MedicalBackgroundPainter(
                color: isDark
                    ? AppColors.primary.withOpacity(0.05)
                    : AppColors.primary.withOpacity(0.03),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: AppConstants.maxContentWidth,
                  ),
                  padding: ResponsiveHelper.getResponsivePadding(context),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      // Feature Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          'AI POWERED',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Hero Title
                      Text(
                        AppConstants.homeTitle,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            48,
                          ),
                          letterSpacing: -1.5,
                          height: 1.1,
                          color: isDark
                              ? Colors.white
                              : AppColors.onSurfaceLight,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Subtitle
                      Text(
                        AppConstants.homeSubtitle,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            18,
                          ),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 60),

                      // Responsive Content Layout
                      Builder(
                        builder: (context) {
                          if (isMobile) {
                            return Column(
                              children: [
                                _buildMobileCard(
                                  context,
                                  'Upload X-Ray',
                                  'Select scan from gallery',
                                  Icons.upload_file_rounded,
                                  AppColors.clientPrimary,
                                  () =>
                                      _handleImageSelection(fromCamera: false),
                                ),
                                const SizedBox(height: 20),
                                _buildMobileCard(
                                  context,
                                  'Take Photo',
                                  'Capture a live X-Ray scan',
                                  Icons.camera_enhance_rounded,
                                  AppColors.studioPrimary,
                                  () => _handleImageSelection(fromCamera: true),
                                ),
                                const SizedBox(height: 20),
                                _buildMobileCard(
                                  context,
                                  'View Reports',
                                  'Access diagnostic history',
                                  Icons.folder_shared_rounded,
                                  AppColors.coachPrimary,
                                  () {},
                                ),
                              ],
                            );
                          } else {
                            // Wide Screen Centralized Design
                            return DragDropZone(
                              onFilesDropped: (files) {
                                if (files.isNotEmpty) {
                                  _handleImageSelection(
                                    fromCamera: false,
                                    dropFile: files.first,
                                  );
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 60,
                                  horizontal: 40,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.03)
                                      : Colors.white.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(
                                    AppConstants.radiusExtraLarge,
                                  ),
                                  border: Border.all(
                                    color: AppColors.primary.withOpacity(0.15),
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(
                                          0.1,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.cloud_upload_outlined,
                                        size: 72,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    Text(
                                      'Drag & Drop X-Ray Scans',
                                      style: theme.textTheme.headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: -0.5,
                                          ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Support for JPG, PNG, and Medical DICOM formats',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: theme.colorScheme.onSurface
                                                .withOpacity(0.6),
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                    const SizedBox(height: 48),
                                    AdaptiveButton(
                                      text: 'Select Scans to Upload',
                                      onPressed: () => _handleImageSelection(
                                        fromCamera: false,
                                      ),
                                      icon: Icons.add_rounded,
                                      width: 320,
                                    ),
                                    const SizedBox(height: 32),
                                    TextButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.history_rounded),
                                      label: const Text(
                                        'View Analysis History',
                                      ),
                                      style: TextButton.styleFrom(
                                        foregroundColor: theme
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.5),
                                        textStyle: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isProcessing)
            Positioned.fill(
              child: Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMobileCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return WorkspaceCard(
      title: title,
      subtitle: subtitle,
      icon: icon,
      themeColor: color,
      features: const [],
      onTap: onTap,
    );
  }
}
