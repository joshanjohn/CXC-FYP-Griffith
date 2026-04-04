import 'dart:typed_data';
import '../services/prediction_service.dart' as api;
import '../models/prediction_response_model.dart';

class PredictionController {
  final api.PredictionService _predictionService = api.PredictionService();

  Future<PredictionResponseModel> predictXRay(
    Uint8List imageBytes,
    String filename, {
    String? modelName,
  }) async {
    return _predictionService.predictXRay(
      imageBytes,
      filename,
      modelName: modelName,
    );
  }

  Future<List<String>> getAvailableModels() async {
    try {
      return await _predictionService.getAvailableModels();
    } catch (e) {
      // Return a default list if fetching fails or handle as needed
      return ['default', 'cxc104'];
    }
  }
}
