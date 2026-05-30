import '../services/model_service.dart';

class ModelController {
  final ModelService modelService = ModelService();

  Future<List<String>> getAvailableModels() async {
    try {
      final responseModel = await modelService.getAvailableModels();
      final filteredModels = responseModel.models
          .where((model) => model.toLowerCase() != 'default')
          .toList();
      return filteredModels.isNotEmpty ? filteredModels : ['cxc201'];
    } catch (e) {
      return const ['cxc201'];
    }
  }
}
