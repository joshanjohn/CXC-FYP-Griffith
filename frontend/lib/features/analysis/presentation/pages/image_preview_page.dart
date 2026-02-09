import 'package:flutter/material.dart';
import '../../../../shared/responsive/responsive_helper.dart';
import '../../../../shared/widgets/adaptive_button.dart';
import '../../../../shared/widgets/image_display_widget.dart';
import '../../../../app/themes/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../widgets/diagnostic_scanner.dart';

/// Screen for previewing and analyzing uploaded X-ray images
class ImagePreviewPage extends StatefulWidget {
  final dynamic imageSource; // File on Mobile/Desktop, Uint8List on Web

  const ImagePreviewPage({super.key, required this.imageSource});

  @override
  State<ImagePreviewPage> createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage>
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
    await Future.delayed(const Duration(seconds: 3));

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
                      ? [AppColors.backgroundDark, AppColors.surfaceDark]
                      : AppColors.backgroundGradient,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                AppBar(
                  title: Text(
                    'Diagnostic Preview',
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
                                      const DiagnosticScanner(),
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
                                )
                              : Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Left: Image
                                    Expanded(
                                      flex: 3,
                                      child: _buildImageCard(
                                        context,
                                        isDark,
                                        isMobile,
                                      ),
                                    ),
                                    const SizedBox(width: 48),
                                    // Right: Results & Actions
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        children: [
                                          if (_isAnalyzing) ...[
                                            const DiagnosticScanner(),
                                            const SizedBox(height: 32),
                                          ] else if (_analysisResults !=
                                              null) ...[
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
        ],
      ),
    );
  }

  Widget _buildImageCard(BuildContext context, bool isDark, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 2,
        ),
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
        color: isDark
            ? AppColors.surfaceDark.withValues(alpha: 0.5)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
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
                  ? 'AI is scanning the X-Ray...'
                  : (_analysisResults == null
                        ? 'Ready for AI processing. Tap analyze to begin.'
                        : 'Analysis complete. Verified by AI diagnostics.'),
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
          color: AppColors.primary.withValues(alpha: 0.15),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
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
            AppColors.accent,
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
          child: Row(
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
        ),
      );
    }
  }
}
