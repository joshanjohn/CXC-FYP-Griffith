class PredictionResponseModel {
  final String prediction;
  final double confidence;

  PredictionResponseModel({
    required this.prediction,
    required this.confidence,
  });

  factory PredictionResponseModel.fromJson(Map<String, dynamic> json) {
    return PredictionResponseModel(
      prediction: json['prediction'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prediction': prediction,
      'confidence': confidence,
    };
  }
}
