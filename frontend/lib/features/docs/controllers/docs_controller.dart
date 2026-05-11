import 'package:frontend/features/docs/models/model_info.dart';
import 'package:frontend/features/docs/services/docs_service.dart';

class DocsController {
  final DocsService docsService = DocsService();

  Future<List<ModelInfo>> getModelsInfo() async {
    return docsService.getModelsInfo();
  }

  Future<ModelInfo?> getModelInfoByName(String modelName) async {
    final models = await getModelsInfo();
    for (final model in models) {
      if (model.name.toLowerCase() == modelName.toLowerCase()) {
        return model;
      }
    }
    return null;
  }
}
