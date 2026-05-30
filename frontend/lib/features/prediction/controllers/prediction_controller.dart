import 'dart:typed_data';
import '../services/prediction_service.dart' as api;
import '../models/prediction_response_model.dart';

class PredictionController {
  final api.PredictionService predictionService = api.PredictionService();

  Future<PredictionResponseModel> predictXRay(
    Uint8List imageBytes,
    String filename, {
    String? modelName,
  }) async {
    return predictionService.predictXRay(
      imageBytes,
      filename,
      modelName: modelName,
    );
  }
}
