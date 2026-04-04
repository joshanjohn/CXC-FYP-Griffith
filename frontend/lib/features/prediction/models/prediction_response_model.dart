class PredictionResponseModel {
  final String prediction;
  final double confidence;
  final String? modelUsed;

  PredictionResponseModel({
    required this.prediction,
    required this.confidence,
    this.modelUsed,
  });

  factory PredictionResponseModel.fromJson(Map<String, dynamic> json) {
    return PredictionResponseModel(
      prediction: json['prediction'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      modelUsed: json['model_used'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prediction': prediction,
      'confidence': confidence,
      'model_used': modelUsed,
    };
  }
}
