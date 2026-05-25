import 'package:flutter/material.dart';
import 'package:cxc/app/themes/app_colors.dart';
import 'package:cxc/shared/widgets/adaptive_button.dart';

class BatchControlPanel extends StatelessWidget {
  final bool isProcessing;
  final bool isComplete;
  final double progress;
  final int totalFiles;
  final int failedCount;
  final VoidCallback onProcess;
  final VoidCallback onDownload;

  const BatchControlPanel({
    super.key,
    required this.isProcessing,
    required this.isComplete,
    required this.progress,
    required this.totalFiles,
    required this.failedCount,
    required this.onProcess,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineLight.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          if (isProcessing) ...[
            LinearProgressIndicator(
              value: progress,
              borderRadius: BorderRadius.circular(10),
              minHeight: 8,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            ),
            const SizedBox(height: 16),
            Text(
              'Processing ${(progress * totalFiles).toInt()} of $totalFiles',
              style: theme.textTheme.bodySmall,
            ),
          ] else
            AdaptiveButton(
              text: isComplete ? 'Restart Process' : 'Start Classification',
              onPressed: onProcess,
              icon: Icons.play_arrow_rounded,
              width: double.infinity,
            ),
          if (isComplete) ...[
            const SizedBox(height: 16),
            if (failedCount > 0) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '$failedCount failed',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            AdaptiveButton(
              text: 'Download Classified ZIP',
              onPressed: onDownload,
              icon: Icons.download_rounded,
              width: double.infinity,
              isPrimary: false,
            ),
          ],
        ],
      ),
    );
  }
}
