import 'package:flutter/material.dart';
import 'package:frontend/app/themes/app_colors.dart';
import 'package:frontend/features/prediction/models/prediction_response_model.dart';

class BatchResultsList extends StatelessWidget {
  final List<PredictionResponseModel> results;
  final bool isProcessing;
  final bool isDark;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const BatchResultsList({
    super.key,
    required this.results,
    required this.isProcessing,
    required this.isDark,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineLight.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Real-time Feed',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 1),
          if (shrinkWrap)
            results.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        isProcessing ? 'Please wait...' : 'No results yet',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    shrinkWrap: true,
                    physics: physics ?? const NeverScrollableScrollPhysics(),
                    itemCount: results.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final result = results[index];
                      return _BatchResultTile(
                        result: result,
                        displayIndex: results.length - index,
                      );
                    },
                  )
          else
            Expanded(
              child: results.isEmpty
                  ? Center(
                      child: Text(
                        isProcessing ? 'Please wait...' : 'No results yet',
                        style: theme.textTheme.bodyMedium,
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      physics: physics,
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final result = results[index];
                        return _BatchResultTile(
                          result: result,
                          displayIndex: results.length - index,
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }
}

class _BatchResultTile extends StatelessWidget {
  final PredictionResponseModel result;
  final int displayIndex;

  const _BatchResultTile({required this.result, required this.displayIndex});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getColorForClass(result.prediction);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineLight.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIconForClass(result.prediction),
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.filename?.isNotEmpty == true
                      ? result.filename!
                      : 'Scan #$displayIndex',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  result.prediction,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${(result.confidence * 100).toStringAsFixed(1)}%',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForClass(String className) {
    switch (className.toUpperCase()) {
      case 'NORMAL':
        return AppColors.success;
      case 'PNEUMONIA':
        return AppColors.error;
      case 'TUBERCULOSIS':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  IconData _getIconForClass(String className) {
    switch (className.toUpperCase()) {
      case 'NORMAL':
        return Icons.check_circle_outline;
      case 'PNEUMONIA':
        return Icons.warning_amber_rounded;
      case 'TUBERCULOSIS':
        return Icons.biotech_outlined;
      default:
        return Icons.help_outline;
    }
  }
}
