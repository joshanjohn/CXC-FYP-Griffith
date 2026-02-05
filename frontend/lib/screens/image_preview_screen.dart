import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';
import '../widgets/adaptive_button.dart';
import '../widgets/image_display_widget.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';

/// Screen for previewing and analyzing uploaded X-ray images
class ImagePreviewScreen extends StatefulWidget {
  final dynamic imageSource; // File on Mobile/Desktop, Uint8List on Web

  const ImagePreviewScreen({super.key, required this.imageSource});

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen>
    with SingleTickerProviderStateMixin {
  bool _isAnalyzing = false;
  Map<String, dynamic>? _analysisResults;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

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
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _analyzeImage() async {
    setState(() => _isAnalyzing = true);

    // TODO: Integrate with your backend API
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Mock results for demonstration
    setState(() {
      _analysisResults = {
        'status': 'success',
        'confidence': 0.94,
        'diagnosis': 'Normal',
        'details':
            'The lung fields are clear. No evidence of pneumonia, tuberculosis, or pleural effusion. Cardiac silhouette is within normal limits.',
      };
      _isAnalyzing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Diagnostic Preview',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SlideTransition(
          position: _slideAnimation,
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: AppConstants.maxContentWidth,
                ),
                padding: ResponsiveHelper.getResponsivePadding(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Image Display with a subtle frame
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusLarge,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusLarge,
                        ),
                        child: ImageDisplayWidget(
                          imageSource: widget.imageSource,
                          maxHeight: isMobile
                              ? MediaQuery.of(context).size.height * 0.45
                              : MediaQuery.of(context).size.height * 0.55,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingExtraLarge),

                    // Analysis Results (if available)
                    if (_analysisResults != null) ...[
                      _buildAnalysisResults(context),
                      const SizedBox(height: AppConstants.paddingExtraLarge),
                    ],

                    // Action Buttons
                    _buildActionButtons(context),
                    const SizedBox(height: AppConstants.paddingLarge),

                    // Info Card
                    Container(
                      padding: const EdgeInsets.all(AppConstants.paddingMedium),
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark
                            ? AppColors.surfaceDark
                            : Colors.white,
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusMedium,
                        ),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.verified_rounded,
                            color: AppColors.success,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _analysisResults == null
                                  ? 'Ready for AI processing. Tap analyze to begin.'
                                  : 'Analysis complete. Verified by AI diagnostics.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.8,
                                ),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
    );
  }

  Widget _buildAnalysisResults(BuildContext context) {
    final theme = Theme.of(context);
    final results = _analysisResults!;
    final confidence = (results['confidence'] as double) * 100;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingExtraLarge),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? AppColors.surfaceDark
            : Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
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
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
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
            results['diagnosis'] as String,
            Icons.medical_services_rounded,
            AppColors.primary,
          ),
          const SizedBox(height: 20),
          _buildResultRow(
            context,
            'Clinical Observations',
            results['details'] as String,
            Icons.article_rounded,
            AppColors.secondary,
          ),
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
            color: color.withOpacity(0.1),
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
          AdaptiveButton(
            text: _analysisResults == null ? 'Process X-Ray' : 'Re-Analyze',
            onPressed: _analyzeImage,
            icon: Icons.biotech_rounded,
            isLoading: _isAnalyzing,
            isPrimary: true,
            width: double.infinity,
          ),
          const SizedBox(height: 12),
          AdaptiveButton(
            text: 'Discard & New',
            onPressed: () => Navigator.pop(context),
            icon: Icons.delete_sweep_rounded,
            isPrimary: false,
            width: double.infinity,
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: AdaptiveButton(
              text: 'Discard & New',
              onPressed: () => Navigator.pop(context),
              icon: Icons.delete_sweep_rounded,
              isPrimary: false,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: AdaptiveButton(
              text: _analysisResults == null ? 'Process X-Ray' : 'Re-Analyze',
              onPressed: _analyzeImage,
              icon: Icons.biotech_rounded,
              isLoading: _isAnalyzing,
              isPrimary: true,
            ),
          ),
        ],
      );
    }
  }
}
