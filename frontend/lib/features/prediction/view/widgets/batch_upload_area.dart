import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:cxc/app/themes/app_colors.dart';

class BatchUploadArea extends StatelessWidget {
  final bool isDark;
  final bool isProcessing;
  final int selectedFileCount;
  final VoidCallback onTap;

  const BatchUploadArea({
    super.key,
    required this.isDark,
    required this.isProcessing,
    required this.selectedFileCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: isProcessing ? null : onTap,
      child: DottedBorder(
        color: AppColors.primary.withValues(alpha: 0.3),
        strokeWidth: 2,
        dashPattern: const [8, 4],
        borderType: BorderType.RRect,
        radius: const Radius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(
                Icons.collections_outlined,
                size: 48,
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                selectedFileCount == 0
                    ? 'Select Images'
                    : '$selectedFileCount files selected',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
               Text(
                'JPG and PNG supported',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
