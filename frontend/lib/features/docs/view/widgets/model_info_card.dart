import 'package:flutter/material.dart';
import 'package:cxc/app/themes/app_colors.dart';
import 'package:cxc/features/docs/models/model_info.dart';
import 'package:cxc/features/docs/view/widgets/model_metric_chip.dart';

class ModelInfoCard extends StatelessWidget {
  const ModelInfoCard({
    super.key,
    required this.modelInfo,
    required this.onTap,
  });

  final ModelInfo modelInfo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      modelInfo.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (modelInfo.isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Default',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                modelInfo.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  height: 1.35,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: ModelMetricChip(
                      label: 'Model Acc.',
                      value: modelInfo.modelAccuracy,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ModelMetricChip(
                      label: 'Val Acc.',
                      value: modelInfo.valAccuracy,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
