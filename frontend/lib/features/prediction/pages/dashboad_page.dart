import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../data/datasources/image_datasource.dart';
import '../../../app/themes/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/responsive/responsive_helper.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/drag_drop_zone.dart';
import '../../../shared/widgets/adaptive_button.dart';
import 'image_preview_page.dart';
import 'permission_error_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
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
          // path conversion varies a bit by platform
          source = File((result as dynamic).path);
        }

        if (!mounted) return;
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
    final isDeviceMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: ResponsiveHelper.getResponsivePadding(context),
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: AppConstants.maxContentWidth,
                  ),
                  child: Column(
                    children: [
                      if (isMobile) ...[
                        _buildHeroSection(context, theme, isDark),
                        const SizedBox(height: 48),
                        _buildMobileUpload(context, isDeviceMobile),
                      ] else ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // title and subtitle on the left
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildFeatureBadge(theme),
                                  const SizedBox(height: 24),
                                  _buildHeroText(
                                    context,
                                    theme,
                                    isDark,
                                    textAlign: TextAlign.left,
                                  ),
                                  const SizedBox(height: 24),
                                  _buildSubtitleText(
                                    context,
                                    theme,
                                    textAlign: TextAlign.left,
                                  ),
                                  const SizedBox(height: 8),
                                  _buildWarningText(
                                    context,
                                    theme,
                                    textAlign: TextAlign.left,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 80),
                            // drop zone on the right
                            Expanded(
                              flex: 1,
                              child: _buildUploadZone(context, theme, isDark),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 167, 35, 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'CXC1',
        style: theme.textTheme.labelMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildHeroText(
    BuildContext context,
    ThemeData theme,
    bool isDark, {
    TextAlign textAlign = TextAlign.center,
  }) {
    return Text(
      AppConstants.homeTitle,
      textAlign: textAlign,
      style: theme.textTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.w900,
        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 48),
        letterSpacing: -1.5,
        height: 1.1,
        color: isDark ? Colors.white : AppColors.onSurfaceLight,
      ),
    );
  }

  Widget _buildSubtitleText(
    BuildContext context,
    ThemeData theme, {
    TextAlign textAlign = TextAlign.center,
  }) {
    return Text(
      AppConstants.homeSubtitle,
      textAlign: textAlign,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildWarningText(
    BuildContext context,
    ThemeData theme, {
    TextAlign textAlign = TextAlign.center,
  }) {
    return Text(
      AppConstants.homeWarning,
      textAlign: textAlign,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 11),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, ThemeData theme, bool isDark) {
    return Column(
      children: [
        const SizedBox(height: 40),
        _buildFeatureBadge(theme),
        const SizedBox(height: 24),
        _buildHeroText(context, theme, isDark),
        const SizedBox(height: 16),
        _buildSubtitleText(context, theme),
        _buildWarningText(context, theme),
      ],
    );
  }

  Widget _buildMobileUpload(BuildContext context, bool isDeviceMobile) {
    return Column(
      children: [
        _buildMobileCard(
          context: context,
          title: 'Upload X-Ray',
          subtitle: 'Select scan from gallery',
          icon: Icons.upload_file_rounded,
          color: AppColors.primary,
          onTap: () => _handleImageSelection(fromCamera: false),
        ),
        if (isDeviceMobile) ...[
          const SizedBox(height: 20),
          _buildMobileCard(
            context: context,
            title: 'Take Photo',
            subtitle: 'Capture a live X-Ray scan',
            icon: Icons.camera_enhance_rounded,
            color: AppColors.primaryDark,
            onTap: () => _handleImageSelection(fromCamera: true),
          ),
        ],
      ],
    );
  }

  Widget _buildUploadZone(BuildContext context, ThemeData theme, bool isDark) {
    return DragDropZone(
      onFilesDropped: (files) {
        if (files.isNotEmpty) {
          _handleImageSelection(fromCamera: false, dropFile: files.first);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.outlineLight, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_upload_outlined,
                size: 72,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Drag & Drop X-Ray Scans',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Support for JPG, PNG, and Medical DICOM formats',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 48),
            AdaptiveButton(
              text: 'Browse Files',
              onPressed: () => _handleImageSelection(fromCamera: false),
              icon: Icons.add_rounded,
              width: 240,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return DashboardCard(
      title: title,
      subtitle: subtitle,
      icon: icon,
      themeColor: color,
      features: const [],
      onTap: onTap,
    );
  }
}
