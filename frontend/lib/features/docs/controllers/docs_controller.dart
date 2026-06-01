import 'package:cxc/features/docs/models/model_info.dart';
import 'package:cxc/features/docs/services/docs_service.dart';

class DocsController {
  // Private constructor for singleton implementation
  DocsController._();

  // Single shared instance
  static final DocsController instance = DocsController._();

  // Factory constructor returns the same instance
  factory DocsController() => instance;

  // Service responsible for fetching model documentation data
  final DocsService docsService = DocsService();

  // Stores ongoing API request to prevent duplicate calls
  Future<List<ModelInfo>>? modelsFuture;

  // Stores previously fetched model information
  List<ModelInfo>? cachedModels;

  Future<List<ModelInfo>> getModelsInfo({bool forceRefresh = false}) async {
    // Clear cache and reload data when refresh is requested
    if (forceRefresh) {
      modelsFuture = null;
      cachedModels = null;
    }

    // Fetch model information only once
    modelsFuture ??= docsService.getModelsInfo();

    // Wait for API response
    final models = await modelsFuture!;

    // Cache the retrieved models
    cachedModels = models;

    return models;
  }

  void seedModels(List<ModelInfo> models) {
    // Preload model data into cache
    cachedModels = models;

    // Create a completed future with cached data
    modelsFuture = Future.value(models);
  }

  Future<ModelInfo?> getModelInfoByName(
    String modelName, {
    ModelInfo? fallback,
  }) async {
    // Return fallback if it matches the requested model
    if (fallback != null &&
        fallback.name.toLowerCase() == modelName.toLowerCase()) {
      return fallback;
    }

    // Use cached models or fetch them if unavailable
    final models = cachedModels ?? await getModelsInfo();

    // Search for the requested model
    for (final model in models) {
      if (model.name.toLowerCase() == modelName.toLowerCase()) {
        return model;
      }
    }

    // Return null if model is not found
    return null;
  }
}