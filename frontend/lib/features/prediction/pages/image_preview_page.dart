import 'package:flutter/material.dart';
import '../../../shared/responsive/responsive_helper.dart';
import '../../../shared/widgets/adaptive_button.dart';
import '../../../shared/widgets/image_display_widget.dart';
import '../../../app/themes/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../controllers/prediction_controller.dart';
import '../models/prediction_response_model.dart';
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
  bool _isAnalyzing = false;
  PredictionResponseModel? _analysisResults;
  final _predictionController = PredictionController();
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  String _selectedModel = 'default';
  List<String> _availableModels = ['default'];

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _slideController.forward();
    _fetchModels();
  }

  Future<void> _fetchModels() async {
    final models = await _predictionController.getAvailableModels();
    if (mounted) {
      setState(() {
        _availableModels = models;
        if (!_availableModels.contains(_selectedModel)) {
          _selectedModel = _availableModels.isNotEmpty ? _availableModels.first : 'default';
        }
      });
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _analyzeImage() async {
    setState(() => _isAnalyzing = true);

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

      final results = await _predictionController.predictXRay(
        imageBytes,
        filename,
        modelName: _selectedModel,
      );

      setState(() {
        _analysisResults = results;
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
        _isAnalyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppBar(
              title: Text(
                AppConstants.analysisTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: isDark ? Colors.white : AppColors.onSurfaceLight,
                ),
              ),
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: isDark ? Colors.white : AppColors.onSurfaceLight,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: SlideTransition(
                position: _slideAnimation,
                child: Center(
                  child: SingleChildScrollView(
                    padding: ResponsiveHelper.getResponsivePadding(context),
                    child: Container(
                      constraints: const BoxConstraints(
                        maxWidth: AppConstants.maxContentWidth,
                      ),
                      child: isMobile
                          ? Column(
                              children: [
                                _buildImageCard(context, isDark, isMobile),
                                const SizedBox(height: 32),
                                if (_isAnalyzing) ...[
                                  const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  const SizedBox(height: 32),
                                ] else if (_analysisResults != null) ...[
                                  _buildAnalysisResults(context),
                                  const SizedBox(height: 32),
                                ],
                                if (!_isAnalyzing) _buildActionButtons(context),
                                const SizedBox(height: 24),
                                _buildModernStatusCard(context, theme, isDark),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // image on the left
                                Expanded(
                                  flex: 3,
                                  child: _buildImageCard(
                                    context,
                                    isDark,
                                    isMobile,
                                  ),
                                ),
                                const SizedBox(width: 48),
                                // results & buttons on the right
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    children: [
                                      if (_isAnalyzing) ...[
                                        const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                        const SizedBox(height: 32),
                                      ] else if (_analysisResults != null) ...[
                                        _buildAnalysisResults(context),
                                        const SizedBox(height: 32),
                                      ],
                                      if (!_isAnalyzing)
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
            _isAnalyzing
                ? Icons.hourglass_empty_rounded
                : Icons.verified_rounded,
            color: _isAnalyzing ? AppColors.warning : AppColors.success,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _isAnalyzing
                  ? AppConstants.analysisScanning
                  : (_analysisResults == null
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
    final results = _analysisResults!;
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
            text: _analysisResults == null ? 'Analyze Scan' : 'Re-Analyze',
            onPressed: _analyzeImage,
            icon: Icons.biotech_rounded,
            isLoading: _isAnalyzing,
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
                      text: _analysisResults == null
                          ? 'Process Scan'
                          : 'Re-Analyze',
                      onPressed: _analyzeImage,
                      icon: Icons.biotech_rounded,
                      isLoading: _isAnalyzing,
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: AppColors.outlineLight),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedModel,
          isExpanded: true,
          dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
          icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.primary),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
          onChanged: _isAnalyzing
              ? null
              : (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedModel = newValue;
                    });
                  }
                },
          items: _availableModels.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text('Model: ${value.toUpperCase()}'),
            );
          }).toList(),
        ),
      ),
    );
  }
}
