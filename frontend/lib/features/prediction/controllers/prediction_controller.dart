  import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../../core/constants/app_variables.dart';
import '../../../core/utils/platform_url.dart';
import '../models/prediction_response_model.dart';

class PredictionController {
  //  final String _baseUrl = BE_URI; // production 
  final String _baseUrl = resolveBackendUrl(BE_URI);

  Future<PredictionResponseModel> predictXRay(
    Uint8List imageBytes,
    String filename,
  ) async {
    final uri = Uri.parse('$_baseUrl/predict');
    final request = http.MultipartRequest('POST', uri);

    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      imageBytes,
      filename: filename,
      contentType: MediaType('image', 'jpeg'), // good enough for most x-rays
    );

    request.files.add(multipartFile);

    try {
      final response = await request.send();
      final responseDataString = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final decodedData = json.decode(responseDataString);
        return PredictionResponseModel.fromJson(decodedData);
      } else {
        throw Exception(
          'Failed to get prediction: ${response.statusCode} - $responseDataString',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
