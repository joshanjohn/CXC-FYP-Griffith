import 'package:flutter/material.dart';
import 'package:frontend/app/routes.dart';
import 'package:frontend/features/docs/controllers/docs_controller.dart';
import 'package:frontend/features/docs/models/model_info.dart';
import 'package:frontend/features/docs/view/widgets/model_info_card.dart';

class ModelsInfoPage extends StatefulWidget {
  const ModelsInfoPage({super.key});

  @override
  State<ModelsInfoPage> createState() => ModelsInfoPageState();
}

class ModelsInfoPageState extends State<ModelsInfoPage> {
  final DocsController docsController = DocsController();
  late final Future<List<ModelInfo>> modelsFuture;

  @override
  void initState() {
    super.initState();
    modelsFuture = docsController.getModelsInfo();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ModelInfo>>(
      future: modelsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Failed to load model docs: ${snapshot.error}'),
          );
        }

        final models = snapshot.data ?? const <ModelInfo>[];
        if (models.isEmpty) {
          return const Center(child: Text('No model documentation available.'));
        }

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: GridView.builder(
              padding: const EdgeInsets.all(24),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 340,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                mainAxisExtent: 220,
              ),
              itemCount: models.length,
              itemBuilder: (context, index) {
                final modelInfo = models[index];
                return ModelInfoCard(
                  modelInfo: modelInfo,
                  onTap: () => Navigator.pushNamed(
                    context,
                    '${AppRoutes.docsModelBase}/${modelInfo.name}',
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
