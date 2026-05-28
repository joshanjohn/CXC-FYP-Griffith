import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cxc/app/themes/app_colors.dart';
import 'package:cxc/core/constants/app_constants.dart';
import 'package:cxc/core/utils/download_file/download_file.dart';
import 'package:cxc/features/prediction/models/prediction_response_model.dart';
import 'package:cxc/features/prediction/services/prediction_service.dart';
import 'package:cxc/features/prediction/view/widgets/batch_aggregation_stats.dart';
import 'package:cxc/features/prediction/view/widgets/batch_control_panel.dart';
import 'package:cxc/features/prediction/view/widgets/batch_results_list.dart';
import 'package:cxc/features/prediction/view/widgets/batch_upload_area.dart';
import 'package:cxc/shared/responsive/responsive_helper.dart';

class BatchPredictionPage extends StatefulWidget {
  const BatchPredictionPage({super.key});

  @override
  State<BatchPredictionPage> createState() => BatchPredictionPageState();
}

class BatchPredictionPageState extends State<BatchPredictionPage> {
  final PredictionService predictionService = PredictionService();

  List<PlatformFile> selectedFiles = [];
  bool isProcessing = false;
  String? sessionId;
  List<PredictionResponseModel> results = [];
  Map<String, int> aggregation = {};
  double progress = 0;
  bool isComplete = false;
  final List<String> failedFiles = [];

  void showMessage(String message, {Color? backgroundColor}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  Future<void> handlePickFilesTap() async {
    try {
      await pickFiles();
    } catch (e) {
      debugPrint('Batch picker error: $e');
      showMessage(
        'Could not open the file picker. Please try again.',
        backgroundColor: AppColors.error,
      );
    }
  }

  Future<void> handleDownloadTap() async {
    try {
      await downloadZip();
    } catch (e) {
      debugPrint('Batch download error: $e');
      showMessage(
        'Could not start the ZIP download.',
        backgroundColor: AppColors.error,
      );
    }
  }

  Future<void> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      withData: kIsWeb || (!kIsWeb && Platform.isMacOS),
    );

    if (result != null) {
      setState(() {
        selectedFiles = result.files;
        results = [];
        aggregation = {};
        progress = 0;
        isComplete = false;
        sessionId = null;
        failedFiles.clear();
      });
    }
  }

  Future<void> processBatch() async {
    if (selectedFiles.isEmpty || isProcessing) return;

    setState(() {
      isProcessing = true;
      results = [];
      aggregation = {};
      progress = 0;
      failedFiles.clear();
    });

    try {
      // 1. Start Session
      sessionId = await predictionService.startBatchSession();

      // 2. Process files in chunks so the backend can run batched inference.
      for (
        int start = 0;
        start < selectedFiles.length;
        start += AppConstants.batchChunkSize
      ) {
        final end = (start + AppConstants.batchChunkSize < selectedFiles.length)
            ? start + AppConstants.batchChunkSize
            : selectedFiles.length;
        final chunk = selectedFiles.sublist(start, end);
        final batchInputs = <BatchImageInput>[];

        for (final file in chunk) {
          try {
            final bytes = await readSelectedFile(file);
            batchInputs.add(BatchImageInput(bytes: bytes, filename: file.name));
          } catch (e) {
            debugPrint('Error reading ${file.name}: $e');
            failedFiles.add(file.name);
          }
        }

        if (batchInputs.isEmpty) {
          if (!mounted) continue;
          setState(() {
            progress = end / selectedFiles.length;
          });
          continue;
        }

        try {
          final chunkResults = await predictionService.predictBatchImages(
            sessionId!,
            batchInputs,
          );

          if (!mounted) continue;
          setState(() {
            for (final result in chunkResults.reversed) {
              results.insert(0, result);
              aggregation[result.prediction] =
                  (aggregation[result.prediction] ?? 0) + 1;
            }
            progress = end / selectedFiles.length;
          });
        } catch (e) {
          debugPrint('Error classifying chunk $start-$end: $e');
          if (!mounted) continue;
          setState(() {
            failedFiles.addAll(batchInputs.map((file) => file.filename));
            progress = end / selectedFiles.length;
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
        showMessage(message, backgroundColor: AppColors.warning);
      }
    } catch (e) {
      showMessage('Batch Error: $e', backgroundColor: AppColors.error);
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  Future<Uint8List> readSelectedFile(PlatformFile file) async {
    if (file.bytes != null) {
      return file.bytes!;
    }

    if (kIsWeb) {
      if (file.bytes == null) {
        throw Exception(
          'Missing browser file data for ${file.name}. Please reselect the file.',
        );
      }
      return file.bytes!;
    }

    final filePath = file.path;
    if (filePath == null) {
      throw Exception(
        'Missing local path for ${file.name}. Please reselect the file.',
      );
    }

    return File(filePath).readAsBytes();
  }

  Future<void> downloadZip() async {
    if (sessionId == null) return;
    final download = await predictionService.downloadBatchZip(sessionId!);
    final savedPath = await saveDownloadedFile(
      download.bytes,
      download.filename,
    );

    if (!mounted) return;

    if (kIsWeb) {
      showMessage('ZIP download started.');
      return;
    }

    if (savedPath != null) {
      showMessage('ZIP saved to $savedPath');
      return;
    }

    showMessage('ZIP download cancelled.');
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
              buildHeader(theme),
              const SizedBox(height: 24),
              Expanded(
                child: isMobile
                    ? SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildUploadArea(isDark, theme),
                            const SizedBox(height: 16),
                            if (selectedFiles.isNotEmpty)
                              buildControlPanel(theme),
                            if (selectedFiles.isNotEmpty)
                              const SizedBox(height: 16),
                            if (aggregation.isNotEmpty)
                              buildAggregationStats(theme),
                            if (aggregation.isNotEmpty)
                              const SizedBox(height: 24),
                            buildResultsList(theme, isDark, shrinkWrap: true),
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
                                buildUploadArea(isDark, theme),
                                const SizedBox(height: 24),
                                if (selectedFiles.isNotEmpty)
                                  buildControlPanel(theme),
                                const SizedBox(height: 24),
                                if (aggregation.isNotEmpty)
                                  buildAggregationStats(theme),
                              ],
                            ),
                          ),
                          const SizedBox(width: 32),
                          // Right Side: Real-time Results
                          Expanded(
                            flex: 3,
                            child: buildResultsList(theme, isDark),
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

  Widget buildHeader(ThemeData theme) {
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

  Widget buildUploadArea(bool isDark, ThemeData theme) {
    return BatchUploadArea(
      isDark: isDark,
      isProcessing: isProcessing,
      selectedFileCount: selectedFiles.length,
      onTap: handlePickFilesTap,
    );
  }

  Widget buildControlPanel(ThemeData theme) {
    return BatchControlPanel(
      isProcessing: isProcessing,
      isComplete: isComplete,
      progress: progress,
      totalFiles: selectedFiles.length,
      failedCount: failedFiles.length,
      onProcess: processBatch,
      onDownload: handleDownloadTap,
    );
  }

  Widget buildAggregationStats(ThemeData theme) {
    return BatchAggregationStats(aggregation: aggregation);
  }

  Widget buildResultsList(
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
