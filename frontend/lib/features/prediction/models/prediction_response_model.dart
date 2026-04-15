class PredictionResponseModel {
  final String prediction;
  final double confidence;
  final Map<String, double> allConfidences;
  final String? modelUsed;
  final String? filename;

  PredictionResponseModel({
    required this.prediction,
    required this.confidence,
    required this.allConfidences,
    this.modelUsed,
    this.filename,
  });

  factory PredictionResponseModel.fromJson(Map<String, dynamic> json) {
    return PredictionResponseModel(
      prediction: json['prediction'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      allConfidences: (json['all_confidences'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
      modelUsed: json['model_used'] as String?,
      filename: json['filename'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prediction': prediction,
      'confidence': confidence,
      'all_confidences': allConfidences,
      'model_used': modelUsed,
      'filename': filename,
    };
  }
}
