import 'package:flutter/material.dart';
import 'package:cxc/features/docs/controllers/docs_controller.dart';
import 'package:cxc/features/docs/models/model_info.dart';
import 'package:cxc/features/docs/view/widgets/models_grid.dart';

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
        docsController.seedModels(models);

        if (models.isEmpty) {
          return const Center(child: Text('No model documentation available.'));
        }

        return ModelsGrid(models: models);
      },
    );
  }
}
