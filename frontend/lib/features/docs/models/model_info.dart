class ModelInfo {
  const ModelInfo({
    required this.alias,
    required this.name,
    required this.description,
    required this.modelAccuracy,
    required this.valAccuracy,
    required this.testConfusionImg,
    required this.testRocImg,
    required this.valConfusionImg,
    required this.valRocImg,
    required this.isDefault,
  });

  final String alias;
  final String name;
  final String description;
  final double modelAccuracy;
  final double valAccuracy;
  final String testConfusionImg;
  final String testRocImg;
  final String valConfusionImg;
  final String valRocImg;
  final bool isDefault;

  factory ModelInfo.fromJson(Map<String, dynamic> json) {
    return ModelInfo(
      alias: json['alias'] as String? ?? (json['name'] as String).toLowerCase(),
      name: json['name'] as String,
      description: json['description'] as String,
      modelAccuracy: (json['model_accuracy'] as num).toDouble(),
      valAccuracy: (json['val_accuracy'] as num).toDouble(),
      testConfusionImg: json['test_confusion_img'] as String,
      testRocImg: json['test_roc_img'] as String,
      valConfusionImg: json['val_confusion_img'] as String,
      valRocImg: json['val_roc_img'] as String,
      isDefault: json['is_default'] as bool? ?? false,
    );
  }
}
