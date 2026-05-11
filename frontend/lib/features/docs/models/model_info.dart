class ModelInfo {
  const ModelInfo({
    required this.name,
    required this.description,
    required this.modelAccuracy,
    required this.valAccuracy,
    required this.testConfusionImg,
    required this.testRocImg,
    required this.valConfusionImg,
    required this.valRocImg,
  });

  final String name;
  final String description;
  final double modelAccuracy;
  final double valAccuracy;
  final String testConfusionImg;
  final String testRocImg;
  final String valConfusionImg;
  final String valRocImg;

  factory ModelInfo.fromJson(Map<String, dynamic> json) {
    return ModelInfo(
      name: json['name'] as String,
      description: json['description'] as String,
      modelAccuracy: (json['model_accuracy'] as num).toDouble(),
      valAccuracy: (json['val_accuracy'] as num).toDouble(),
      testConfusionImg: json['test_confusion_img'] as String,
      testRocImg: json['test_roc_img'] as String,
      valConfusionImg: json['val_confusion_img'] as String,
      valRocImg: json['val_roc_img'] as String,
    );
  }
}
