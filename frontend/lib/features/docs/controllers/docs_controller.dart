import 'package:cxc/features/docs/models/model_info.dart';
import 'package:cxc/features/docs/services/docs_service.dart';

class DocsController {
  DocsController._();

  static final DocsController instance = DocsController._();

  factory DocsController() => instance;

  final DocsService docsService = DocsService();
  Future<List<ModelInfo>>? modelsFuture;
  List<ModelInfo>? cachedModels;

  Future<List<ModelInfo>> getModelsInfo({bool forceRefresh = false}) async {
    if (forceRefresh) {
      modelsFuture = null;
      cachedModels = null;
    }

    modelsFuture ??= docsService.getModelsInfo();
    final models = await modelsFuture!;
    cachedModels = models;
    return models;
  }

  void seedModels(List<ModelInfo> models) {
    cachedModels = models;
    modelsFuture = Future.value(models);
  }

  Future<ModelInfo?> getModelInfoByName(
    String modelName, {
    ModelInfo? fallback,
  }) async {
    if (fallback != null &&
        fallback.name.toLowerCase() == modelName.toLowerCase()) {
      return fallback;
    }

    final models = cachedModels ?? await getModelsInfo();
    for (final model in models) {
      if (model.name.toLowerCase() == modelName.toLowerCase()) {
        return model;
      }
    }
    return null;
  }
}
