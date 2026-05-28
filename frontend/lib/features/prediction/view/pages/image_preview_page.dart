import 'package:flutter/material.dart';
import 'package:cxc/app/routes.dart';
import 'package:cxc/shared/responsive/responsive_helper.dart';
import 'package:cxc/shared/widgets/adaptive_button.dart';
import 'package:cxc/shared/widgets/image_display_widget.dart';
import 'package:cxc/app/themes/app_colors.dart';
import 'package:cxc/core/constants/app_constants.dart';
import 'package:cxc/features/prediction/controllers/prediction_controller.dart';
import 'package:cxc/features/prediction/models/prediction_response_model.dart';
import 'package:cxc/features/prediction/view/widgets/prediction_chart.dart';
import 'package:cxc/shared/widgets/persistent_top_nav.dart';
import 'dart:io' as io;
import 'dart:typed_data';

// shows the uploaded x-ray and lets you run the model on it
class ImagePreviewPage extends StatefulWidget {
  final dynamic imageSource; // File on mobile/desktop, bytes on web

  const ImagePreviewPage({super.key, required this.imageSource});

  @override
  State<ImagePreviewPage> createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage>
    with SingleTickerProviderStateMixin {
  bool isAnalyzing = false;
  PredictionResponseModel? analysisResults;
  final predictionController = PredictionController();
  late AnimationController slideController;
  late Animation<Offset> slideAnimation;

  String selectedModel = 'cxc201';
  List<String> availableModels = const ['cxc201'];

  @override
  void initState() {
    super.initState();
    slideController = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );
    slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: slideController, curve: Curves.easeOut));
    slideController.forward();
    _fetchModels();
  }

  Future<void> _fetchModels() async {
    final models = await predictionController.getAvailableModels();
    if (mounted) {
      setState(() {
        availableModels = models
            .where((model) => model.toLowerCase() != 'default')
            .toList();
        if (availableModels.isNotEmpty) {
          selectedModel = availableModels.first;
        }
      });
    }
  }

  @override
  void dispose() {
    slideController.dispose();
    super.dispose();
  }

  Future<void> _analyzeImage() async {
    setState(() => isAnalyzing = true);

    try {
      Uint8List imageBytes;
      String filename = 'upload.jpg';

      if (widget.imageSource is Uint8List) {
        // Web: raw bytes
        imageBytes = widget.imageSource as Uint8List;
      } else if (widget.imageSource is io.File) {
        // Mobile/Desktop: dart:io File
        final file = widget.imageSource as io.File;
        imageBytes = await file.readAsBytes();
        filename = file.path.split('/').last;
      } else {
        // XFile or similar cross-platform type (has .readAsBytes() and .name)
        try {
          imageBytes = await widget.imageSource.readAsBytes();
          filename = widget.imageSource.name ?? 'upload.jpg';
        } catch (e) {
          throw Exception(
            'Unsupported image source type: ${widget.imageSource.runtimeType}',
          );
        }
      }

      final results = await predictionController.predictXRay(
        imageBytes,
        filename,
        modelName: selectedModel,
      );

      setState(() {
        analysisResults = results;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error analyzing image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isAnalyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = ResponsiveHelper.isMobile(context);
    final showCameraItem = ResponsiveHelper.isPlatformMobile();

    return Scaffold(
      body: Column(
        children: [
          PersistentTopNav(
            title: AppConstants.analysisTitle,
            items: [
              PersistentTopNavItem(
                label: 'Home',
                icon: Icons.home_rounded,
                isActive: false,
                onTap: () => Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.workspace,
                ),
              ),
              if (showCameraItem)
                PersistentTopNavItem(
                  label: 'Camera',
                  icon: Icons.camera_alt_rounded,
                  isActive: false,
                  onTap: () => Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.workspace,
                  ),
                ),
              PersistentTopNavItem(
                label: 'Batch',
                icon: Icons.layers_rounded,
                isActive: false,
                onTap: () =>
                    Navigator.pushReplacementNamed(context, AppRoutes.batch),
              ),
              PersistentTopNavItem(
                label: 'Docs',
                icon: Icons.library_books_rounded,
                isActive: false,
                onTap: () =>
                    Navigator.pushReplacementNamed(context, AppRoutes.docs),
              ),
              PersistentTopNavItem(
                label: 'Profile',
                icon: Icons.person_rounded,
                isActive: false,
                onTap: () =>
                    Navigator.pushReplacementNamed(context, AppRoutes.profile),
              ),
            ],
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: SlideTransition(
                position: slideAnimation,
                child: Center(
                  child: SingleChildScrollView(
                    padding: ResponsiveHelper.getResponsivePadding(context),
                    child: Container(
                      constraints: const BoxConstraints(
                        maxWidth: AppConstants.maxContentWidth,
                      ),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back_rounded),
                              label: const Text('Back'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          isMobile
                              ? Column(
                                  children: [
                                    _buildImageCard(context, isDark, isMobile),
                                    const SizedBox(height: 32),
                                    if (isAnalyzing) ...[
                                      const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                      const SizedBox(height: 32),
                                    ] else if (analysisResults != null) ...[
                                      _buildAnalysisResults(context),
                                      const SizedBox(height: 32),
                                    ],
                                    if (!isAnalyzing)
                                      _buildActionButtons(context),
                                    const SizedBox(height: 24),
                                    _buildModernStatusCard(
                                      context,
                                      theme,
                                      isDark,
                                    ),
                                  ],
                                )
                              : Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: _buildImageCard(
                                        context,
                                        isDark,
                                        isMobile,
                                      ),
                                    ),
                                    const SizedBox(width: 48),
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        children: [
                                          if (isAnalyzing) ...[
                                            const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                            const SizedBox(height: 32),
                                          ] else if (analysisResults !=
                                              null) ...[
                                            _buildAnalysisResults(context),
                                            const SizedBox(height: 32),
                                          ],
                                          if (!isAnalyzing)
                                            _buildActionButtons(context),
                                          const SizedBox(height: 24),
                                          _buildModernStatusCard(
                                            context,
                                            theme,
                                            isDark,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                        ],
                      ),
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

  Widget _buildImageCard(BuildContext context, bool isDark, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(color: AppColors.outlineLight, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge - 2),
        child: ImageDisplayWidget(
          imageSource: widget.imageSource,
          maxWidth: 800,
          maxHeight: isMobile
              ? MediaQuery.of(context).size.height * 0.45
              : MediaQuery.of(context).size.height * 0.6,
        ),
      ),
    );
  }

  Widget _buildModernStatusCard(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: AppColors.outlineLight),
      ),
      child: Row(
        children: [
          Icon(
            isAnalyzing
                ? Icons.hourglass_empty_rounded
                : Icons.verified_rounded,
            color: isAnalyzing ? AppColors.warning : AppColors.success,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isAnalyzing
                  ? AppConstants.analysisScanning
                  : (analysisResults == null
                        ? AppConstants.analysisReady
                        : AppConstants.analysisComplete),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisResults(BuildContext context) {
    final theme = Theme.of(context);
    final results = analysisResults!;
    final confidence = results.confidence * 100;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingExtraLarge),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? AppColors.surfaceDark
            : Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(color: AppColors.outlineLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.success,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Diagnostic Result',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Confidence Level: ${confidence.toStringAsFixed(1)}%',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 24),
          _buildResultRow(
            context,
            'Detection Result',
            results.prediction,
            Icons.medical_services_rounded,
            AppColors.primary,
          ),
          if (results.modelUsed != null) ...[
            const SizedBox(height: 16),
            _buildResultRow(
              context,
              'AI Model Used',
              results.modelUsed!.toUpperCase(),
              Icons.settings_suggest_rounded,
              AppColors.accent,
            ),
          ],
          const SizedBox(height: 32),
          const Divider(height: 1),
          const SizedBox(height: 32),
          PredictionChart(allConfidences: results.allConfidences),
        ],
      ),
    );
  }

  Widget _buildResultRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    if (isMobile) {
      return Column(
        children: [
          _buildModelDropdown(context),
          const SizedBox(height: 16),
          AdaptiveButton(
            text: analysisResults == null ? 'Analyze Scan' : 'Re-Analyze',
            onPressed: _analyzeImage,
            icon: Icons.biotech_rounded,
            isLoading: isAnalyzing,
            isPrimary: true,
            width: double.infinity,
          ),
          const SizedBox(height: 12),
          AdaptiveButton(
            text: 'Discard Scan',
            onPressed: () => Navigator.pop(context),
            icon: Icons.delete_sweep_rounded,
            isPrimary: false,
            width: double.infinity,
          ),
        ],
      );
    } else {
      return Center(
        child: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildModelDropdown(context),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AdaptiveButton(
                      text: 'Discard',
                      onPressed: () => Navigator.pop(context),
                      icon: Icons.delete_sweep_rounded,
                      isPrimary: false,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AdaptiveButton(
                      text: analysisResults == null
                          ? 'Analyze'
                          : 'Re-Analyze',
                      onPressed: _analyzeImage,
                      icon: Icons.biotech_rounded,
                      isLoading: isAnalyzing,
                      isPrimary: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildModelDropdown(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final defaultModel = availableModels.isNotEmpty
        ? availableModels.first
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: AppColors.outlineLight),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedModel,
          isExpanded: true,
          dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
          icon: const Icon(
            Icons.arrow_drop_down_rounded,
            color: AppColors.primary,
          ),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
          onChanged: isAnalyzing
              ? null
              : (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedModel = newValue;
                    });
                  }
                },
          items: availableModels.map<DropdownMenuItem<String>>((String value) {
            final isDefaultModel = value == defaultModel;
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                isDefaultModel
                    ? 'Model: ${value.toUpperCase()} (Default)'
                    : 'Model: ${value.toUpperCase()}',
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
