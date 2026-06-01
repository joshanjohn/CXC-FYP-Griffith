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

  // Handle file picker button press
  Future<void> handlePickFilesTap() async {
    try {
      // Open file picker
      await pickFiles();
    } catch (e) {
      // Show error if file picker fails
      debugPrint('Batch picker error: $e');

      showMessage(
        'Could not open the file picker. Please try again.',
        backgroundColor: AppColors.error,
      );
    }
  }

  // Handle ZIP download button press
  Future<void> handleDownloadTap() async {
    try {
      // Start ZIP download
      await downloadZip();
    } catch (e) {
      // Show error if download fails
      debugPrint('Batch download error: $e');

      showMessage(
        'Could not start the ZIP download.',
        backgroundColor: AppColors.error,
      );
    }
  }

  // Select multiple image files
  Future<void> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      withData: kIsWeb || (!kIsWeb && Platform.isMacOS),
    );

    if (result != null) {
      // Reset previous batch results
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

  // Process all selected images
  Future<void> processBatch() async {
    // Prevent duplicate processing
    if (selectedFiles.isEmpty || isProcessing) return;

    // Reset processing state
    setState(() {
      isProcessing = true;
      results = [];
      aggregation = {};
      progress = 0;
      failedFiles.clear();
    });

    try {
      // Create a new batch session on the backend
      sessionId = await predictionService.startBatchSession();

      // Process files in chunks
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

        // Read files in current chunk
        for (final file in chunk) {
          try {
            final bytes = await readSelectedFile(file);

            batchInputs.add(BatchImageInput(bytes: bytes, filename: file.name));
          } catch (e) {
            // Track files that could not be read
            debugPrint('Error reading ${file.name}: $e');

            failedFiles.add(file.name);
          }
        }

        // Skip empty chunks
        if (batchInputs.isEmpty) {
          if (!mounted) continue;

          setState(() {
            progress = end / selectedFiles.length;
          });

          continue;
        }

        try {
          // Send chunk for batch prediction
          final chunkResults = await predictionService.predictBatchImages(
            sessionId!,
            batchInputs,
          );

          if (!mounted) continue;

          setState(() {
            // Store prediction results
            for (final result in chunkResults.reversed) {
              results.insert(0, result);

              // Update class counts
              aggregation[result.prediction] =
                  (aggregation[result.prediction] ?? 0) + 1;
            }

            // Update progress bar
            progress = end / selectedFiles.length;
          });
        } catch (e) {
          // Track failed classifications
          debugPrint('Error classifying chunk $start-$end: $e');

          if (!mounted) continue;

          setState(() {
            failedFiles.addAll(batchInputs.map((file) => file.filename));

            progress = end / selectedFiles.length;
          });
        }
      }

      // Mark batch process as completed
      setState(() {
        isComplete = true;
      });

      // Notify user of failed files
      if (mounted && failedFiles.isNotEmpty) {
        final failureCount = failedFiles.length;

        final message = failureCount == 1
            ? '1 file could not be classified.'
            : '$failureCount files could not be classified.';

        showMessage(message, backgroundColor: AppColors.warning);
      }
    } catch (e) {
      // Show batch processing error
      showMessage('Batch Error: $e', backgroundColor: AppColors.error);
    } finally {
      // Stop loading state
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  // Read selected file bytes
  Future<Uint8List> readSelectedFile(PlatformFile file) async {
    // Use in-memory bytes if available
    if (file.bytes != null) {
      return file.bytes!;
    }

    // Handle web platform
    if (kIsWeb) {
      if (file.bytes == null) {
        throw Exception(
          'Missing browser file data for ${file.name}. Please reselect the file.',
        );
      }

      return file.bytes!;
    }

    // Get local file path
    final filePath = file.path;

    if (filePath == null) {
      throw Exception(
        'Missing local path for ${file.name}. Please reselect the file.',
      );
    }

    // Read file from device storage
    return File(filePath).readAsBytes();
  }

  // Download classified images ZIP file
  Future<void> downloadZip() async {
    // Ensure a session exists
    if (sessionId == null) return;

    // Request ZIP from backend
    final download = await predictionService.downloadBatchZip(sessionId!);

    // Save ZIP file locally
    final savedPath = await saveDownloadedFile(
      download.bytes,
      download.filename,
    );

    if (!mounted) return;

    // Web download message
    if (kIsWeb) {
      showMessage('ZIP download started.');
      return;
    }

    // Successful save message
    if (savedPath != null) {
      showMessage('ZIP saved to $savedPath');
      return;
    }

    // User cancelled save dialog
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
