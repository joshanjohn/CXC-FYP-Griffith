import 'dart:io';
import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';
import '../widgets/adaptive_button.dart';
import '../widgets/image_display_widget.dart';

/// Screen for previewing and analyzing uploaded X-ray images
class ImagePreviewScreen extends StatefulWidget {
  final File imageSource;

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
      duration: const Duration(milliseconds: 600),
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
        'confidence': 0.92,
        'diagnosis': 'Normal',
        'details': 'No abnormalities detected in the chest X-ray.',
      };
      _isAnalyzing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'X-Ray Analysis',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SlideTransition(
          position: _slideAnimation,
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: ResponsiveHelper.getMaxContentWidth(context),
                ),
                padding: ResponsiveHelper.getResponsivePadding(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Image Display
                    ImageDisplayWidget(
                      imageSource: widget.imageSource,
                      maxHeight: isMobile
                          ? MediaQuery.of(context).size.height * 0.5
                          : MediaQuery.of(context).size.height * 0.6,
                    ),
                    SizedBox(height: isMobile ? 24 : 32),

                    // Analysis Results (if available)
                    if (_analysisResults != null) ...[
                      _buildAnalysisResults(context),
                      SizedBox(height: isMobile ? 24 : 32),
                    ],

                    // Action Buttons
                    _buildActionButtons(context),
                    SizedBox(height: isMobile ? 16 : 24),

                    // Info Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withOpacity(
                          0.5,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline_rounded,
                            color: colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _analysisResults == null
                                  ? 'Tap "Analyze" to get AI-powered insights'
                                  : 'Analysis complete! Review the results above.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.8),
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
    final colorScheme = theme.colorScheme;
    final results = _analysisResults!;
    final confidence = (results['confidence'] as double) * 100;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
                  color: colorScheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analysis Complete',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Confidence: ${confidence.toStringAsFixed(1)}%',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
          _buildResultRow(
            context,
            'Diagnosis',
            results['diagnosis'] as String,
            Icons.medical_information_rounded,
          ),
          const SizedBox(height: 16),
          _buildResultRow(
            context,
            'Details',
            results['details'] as String,
            Icons.description_rounded,
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
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: colorScheme.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w500,
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
            text: _analysisResults == null ? 'Analyze X-Ray' : 'Re-Analyze',
            onPressed: _analyzeImage,
            icon: Icons.analytics_rounded,
            isLoading: _isAnalyzing,
            isPrimary: true,
            width: double.infinity,
          ),
          const SizedBox(height: 12),
          AdaptiveButton(
            text: 'Upload Another',
            onPressed: () => Navigator.pop(context),
            icon: Icons.upload_file_rounded,
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
              text: 'Upload Another',
              onPressed: () => Navigator.pop(context),
              icon: Icons.upload_file_rounded,
              isPrimary: false,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: AdaptiveButton(
              text: _analysisResults == null ? 'Analyze X-Ray' : 'Re-Analyze',
              onPressed: _analyzeImage,
              icon: Icons.analytics_rounded,
              isLoading: _isAnalyzing,
              isPrimary: true,
            ),
          ),
        ],
      );
    }
  }
}
