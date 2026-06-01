import '../services/model_service.dart';

class ModelController {
  // Service responsible for communicating with the backend
  final ModelService modelService = ModelService();

  Future<List<String>> getAvailableModels() async {
    try {
      // Fetch available model names from the backend
      final responseModel = await modelService.getAvailableModels();

      // Remove the generic "default" entry from the list
      final filteredModels = responseModel.models
          .where((model) => model.toLowerCase() != 'default')
          .toList();

      // Return fetched models or a fallback model if the list is empty
      return filteredModels.isNotEmpty ? filteredModels : ['cxc201'];
    } catch (e) {
      // Return fallback model if an error occurs
      return const ['cxc201'];
    }
  }
}
