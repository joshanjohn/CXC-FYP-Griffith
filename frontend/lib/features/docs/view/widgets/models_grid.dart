import 'package:flutter/material.dart';
import 'package:cxc/app/routes.dart';
import 'package:cxc/features/docs/models/model_info.dart';
import 'package:cxc/features/docs/view/widgets/model_info_card.dart';

class ModelsGrid extends StatelessWidget {
  const ModelsGrid({
    super.key,
    required this.models,
  });

  final List<ModelInfo> models;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1120),
        child: GridView.builder(
          padding: const EdgeInsets.all(24),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 340,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            mainAxisExtent: 260,
          ),
          itemCount: models.length,
          itemBuilder: (context, index) {
            final modelInfo = models[index];
            return ModelInfoCard(
              modelInfo: modelInfo,
              onTap: () => Navigator.pushNamed(
                context,
                '${AppRoutes.docsModelBase}/${modelInfo.name}',
                arguments: modelInfo,
              ),
            );
          },
        ),
      ),
    );
  }
}
