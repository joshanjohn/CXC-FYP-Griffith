import 'package:flutter/material.dart';
import 'package:cxc/app/themes/app_colors.dart';
import 'package:cxc/features/docs/models/model_info.dart';
import 'package:cxc/features/docs/view/widgets/model_info_stat_card.dart';

class ModelInfoDetailHeader extends StatelessWidget {
  const ModelInfoDetailHeader({
    super.key,
    required this.modelInfo,
  });

  final ModelInfo modelInfo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.12),
            AppColors.primaryDark.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  modelInfo.name,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (modelInfo.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(
                      alpha: 0.12,
                    ),
                    borderRadius: BorderRadius.circular(
                      999,
                    ),
                  ),
                  child: Text(
                    'Default',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            modelInfo.description,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.78),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              ModelInfoStatCard(
                label: 'Model Accuracy',
                value: modelInfo.modelAccuracy.toStringAsFixed(2),
              ),
              ModelInfoStatCard(
                label: 'Validation Accuracy',
                value: modelInfo.valAccuracy.toStringAsFixed(2),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
