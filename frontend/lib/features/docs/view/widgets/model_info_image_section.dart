import 'package:flutter/material.dart';
import 'package:cxc/features/docs/models/model_info.dart';
import 'package:cxc/features/docs/view/widgets/model_info_image_panel.dart';

class ModelInfoImageSection extends StatelessWidget {
  const ModelInfoImageSection({
    super.key,
    required this.modelInfo,
  });

  final ModelInfo modelInfo;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 900;
        final panels = [
          ModelInfoImagePanel(
            title: 'Test Confusion Matrix',
            assetPath: modelInfo.testConfusionImg,
          ),
          ModelInfoImagePanel(
            title: 'Test ROC Curve',
            assetPath: modelInfo.testRocImg,
          ),
          ModelInfoImagePanel(
            title: 'Validation Confusion Matrix',
            assetPath: modelInfo.valConfusionImg,
          ),
          ModelInfoImagePanel(
            title: 'Validation ROC Curve',
            assetPath: modelInfo.valRocImg,
          ),
        ];

        if (!twoColumns) {
          return Column(
            children: [
              for (final panel in panels) ...[
                panel,
                const SizedBox(height: 20),
              ],
            ],
          );
        }

        return Wrap(
          spacing: 20,
          runSpacing: 20,
          children: panels
              .map(
                (panel) => SizedBox(
                  width: (constraints.maxWidth - 20) / 2,
                  child: panel,
                ),
              )
              .toList(),
        );
      },
    );
  }
}
