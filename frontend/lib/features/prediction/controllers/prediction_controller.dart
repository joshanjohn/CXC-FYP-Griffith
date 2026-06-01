import 'dart:typed_data';
import '../services/prediction_service.dart' as api;
import '../models/prediction_response_model.dart';

class PredictionController {
  // Service responsible for handling prediction API requests
  final api.PredictionService predictionService =
      api.PredictionService();

  Future<PredictionResponseModel> predictXRay(
    Uint8List imageBytes,
    String filename, {
    String? modelName,
  }) async {
    // Send X-ray image to the backend for prediction
    return predictionService.predictXRay(
      imageBytes,
      filename,
      modelName: modelName,
    );
  }
}