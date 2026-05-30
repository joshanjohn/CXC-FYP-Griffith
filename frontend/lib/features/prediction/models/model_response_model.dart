class ModelResponseModel {
  final List<String> models;

  ModelResponseModel({
    required this.models,
  });

  factory ModelResponseModel.fromJson(Map<String, dynamic> json) {
    return ModelResponseModel(
      models: List<String>.from(json['models'] as List<dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'models': models,
    };
  }
}
