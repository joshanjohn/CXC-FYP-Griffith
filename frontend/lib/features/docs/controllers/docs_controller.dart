import 'package:frontend/features/docs/models/model_info.dart';
import 'package:frontend/features/docs/services/docs_service.dart';

class DocsController {
  DocsController._();

  static final DocsController _instance = DocsController._();

  factory DocsController() => _instance;

  final DocsService docsService = DocsService();
  Future<List<ModelInfo>>? _modelsFuture;
  List<ModelInfo>? _cachedModels;

  Future<List<ModelInfo>> getModelsInfo({bool forceRefresh = false}) async {
    if (forceRefresh) {
      _modelsFuture = null;
      _cachedModels = null;
    }

    _modelsFuture ??= docsService.getModelsInfo();
    final models = await _modelsFuture!;
    _cachedModels = models;
    return models;
  }

  void seedModels(List<ModelInfo> models) {
    _cachedModels = models;
    _modelsFuture = Future.value(models);
  }

  Future<ModelInfo?> getModelInfoByName(
    String modelName, {
    ModelInfo? fallback,
  }) async {
    if (fallback != null &&
        fallback.name.toLowerCase() == modelName.toLowerCase()) {
      return fallback;
    }

    final models = _cachedModels ?? await getModelsInfo();
    for (final model in models) {
      if (model.name.toLowerCase() == modelName.toLowerCase()) {
        return model;
      }
    }
    return null;
  }
}
