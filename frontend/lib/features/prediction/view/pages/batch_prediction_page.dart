import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:frontend/app/themes/app_colors.dart';
import 'package:frontend/core/utils/download_file/download_file.dart';
import 'package:frontend/features/prediction/services/prediction_service.dart';
import 'package:frontend/features/prediction/models/prediction_response_model.dart';
import 'package:frontend/features/prediction/view/widgets/batch_aggregation_stats.dart';
import 'package:frontend/features/prediction/view/widgets/batch_control_panel.dart';
import 'package:frontend/features/prediction/view/widgets/batch_results_list.dart';
import 'package:frontend/features/prediction/view/widgets/batch_upload_area.dart';
import 'package:frontend/shared/responsive/responsive_helper.dart';

class BatchPredictionPage extends StatefulWidget {
  const BatchPredictionPage({super.key});

  @override
  State<BatchPredictionPage> createState() => _BatchPredictionPageState();
}

class _BatchPredictionPageState extends State<BatchPredictionPage> {
  final PredictionService _predictionService = PredictionService();

  List<PlatformFile> selectedFiles = [];
  bool isProcessing = false;
  String? sessionId;
  List<PredictionResponseModel> results = [];
  Map<String, int> _aggregation = {};
  double progress = 0;
  bool isComplete = false;
  final List<String> failedFiles = [];

  void _showMessage(String message, {Color? backgroundColor}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  Future<void> _handlePickFilesTap() async {
    try {
      await _pickFiles();
    } catch (e) {
      debugPrint('Batch picker error: $e');
      _showMessage(
        'Could not open the file picker. Please try again.',
        backgroundColor: AppColors.error,
      );
    }
  }

  Future<void> _handleDownloadTap() async {
    try {
      await _downloadZip();
    } catch (e) {
      debugPrint('Batch download error: $e');
      _showMessage(
        'Could not start the ZIP download.',
        backgroundColor: AppColors.error,
      );
    }
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      withData: kIsWeb,
    );

    if (result != null) {
      setState(() {
        selectedFiles = result.files;
        results = [];
        _aggregation = {};
        progress = 0;
        isComplete = false;
        sessionId = null;
        failedFiles.clear();
      });
    }
  }

  Future<void> _processBatch() async {
    if (selectedFiles.isEmpty || isProcessing) return;

    setState(() {
      isProcessing = true;
      results = [];
      _aggregation = {};
      progress = 0;
      failedFiles.clear();
    });

    try {
      // 1. Start Session
      sessionId = await _predictionService.startBatchSession();

      // 2. Process Files
      for (int i = 0; i < selectedFiles.length; i++) {
        final file = selectedFiles[i];

        Uint8List bytes;
        if (kIsWeb) {
          if (file.bytes == null) {
            throw Exception(
              'Missing browser file data for ${file.name}. Please reselect the file.',
            );
          }
          bytes = file.bytes!;
        } else {
          final filePath = file.path;
          if (filePath == null) {
            throw Exception(
              'Missing local path for ${file.name}. Please reselect the file.',
            );
          }
          bytes = await File(filePath).readAsBytes();
        }

        try {
          final result = await _predictionService.classifyBatchImage(
            sessionId!,
            bytes,
            file.name,
          );

          setState(() {
            results.insert(0, result);
            _aggregation[result.prediction] =
                (_aggregation[result.prediction] ?? 0) + 1;
            progress = (i + 1) / selectedFiles.length;
          });
        } catch (e) {
          debugPrint('Error classifying ${file.name}: $e');
          if (!mounted) continue;
          setState(() {
            failedFiles.add(file.name);
            progress = (i + 1) / selectedFiles.length;
          });
        }
      }

      setState(() {
        isComplete = true;
      });

      if (mounted && failedFiles.isNotEmpty) {
        final failureCount = failedFiles.length;
        final message = failureCount == 1
            ? '1 file could not be classified.'
            : '$failureCount files could not be classified.';
        _showMessage(message, backgroundColor: AppColors.warning);
      }
    } catch (e) {
      _showMessage('Batch Error: $e', backgroundColor: AppColors.error);
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  Future<void> _downloadZip() async {
    if (sessionId == null) return;
    final download = await _predictionService.downloadBatchZip(sessionId!);
    final savedPath = await saveDownloadedFile(
      download.bytes,
      download.filename,
    );

    if (!mounted) return;

    if (kIsWeb) {
      _showMessage('ZIP download started.');
      return;
    }

    if (savedPath != null) {
      _showMessage('ZIP saved to $savedPath');
      return;
    }

    _showMessage('ZIP downloaded successfully.');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: ResponsiveHelper.getResponsivePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),
              const SizedBox(height: 24),
              Expanded(
                child: isMobile
                    ? SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildUploadArea(isDark, theme),
                            const SizedBox(height: 16),
                            if (selectedFiles.isNotEmpty)
                              _buildControlPanel(theme),
                            if (selectedFiles.isNotEmpty)
                              const SizedBox(height: 16),
                            if (_aggregation.isNotEmpty)
                              _buildAggregationStats(theme),
                            if (_aggregation.isNotEmpty)
                              const SizedBox(height: 24),
                            _buildResultsList(theme, isDark, shrinkWrap: true),
                          ],
                        ),
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Side: Upload & Control
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                _buildUploadArea(isDark, theme),
                                const SizedBox(height: 24),
                                if (selectedFiles.isNotEmpty)
                                  _buildControlPanel(theme),
                                const SizedBox(height: 24),
                                if (_aggregation.isNotEmpty)
                                  _buildAggregationStats(theme),
                              ],
                            ),
                          ),
                          const SizedBox(width: 32),
                          // Right Side: Real-time Results
                          Expanded(
                            flex: 3,
                            child: _buildResultsList(theme, isDark),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final canPop = Navigator.canPop(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (canPop) ...[
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              'Batch Classifier',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(left: canPop ? 48 : 0),
          child: Text(
            'Stream and classify multiple X-ray scans in real-time.',
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  Widget _buildUploadArea(bool isDark, ThemeData theme) {
    return BatchUploadArea(
      isDark: isDark,
      isProcessing: isProcessing,
      selectedFileCount: selectedFiles.length,
      onTap: _handlePickFilesTap,
    );
  }

  Widget _buildControlPanel(ThemeData theme) {
    return BatchControlPanel(
      isProcessing: isProcessing,
      isComplete: isComplete,
      progress: progress,
      totalFiles: selectedFiles.length,
      failedCount: failedFiles.length,
      onProcess: _processBatch,
      onDownload: _handleDownloadTap,
    );
  }

  Widget _buildAggregationStats(ThemeData theme) {
    return BatchAggregationStats(aggregation: _aggregation);
  }

  Widget _buildResultsList(
    ThemeData theme,
    bool isDark, {
    bool shrinkWrap = false,
  }) {
    return BatchResultsList(
      results: results,
      isProcessing: isProcessing,
      isDark: isDark,
      shrinkWrap: shrinkWrap,
    );
  }
}
