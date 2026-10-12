import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/prediction.dart';

/// Calls the Flask model API (api.py) `/predict` endpoint.
class ClassifyService {
  ClassifyService._();
  static final ClassifyService instance = ClassifyService._();

  Uri _url(String path) => Uri.parse('${AppConfig.apiBaseUrl}$path');

  /// Classify [text]. Throws [ClassifyException] with a friendly message on failure.
  Future<Prediction> classify(String text) async {
    if (text.trim().isEmpty) {
      throw const ClassifyException('Please enter some text to analyze.');
    }
    try {
      final res = await http
          .post(
            _url('/predict'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'text': text}),
          )
          .timeout(const Duration(seconds: 30));

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200) {
        return Prediction.fromJson(body);
      }
      if (res.statusCode == 503) {
        throw const ClassifyException(
          'The model is not loaded on the server. Train/place the model files, then restart api.py.',
        );
      }
      throw ClassifyException(
        (body['error'] ?? 'Request failed (${res.statusCode}).').toString(),
      );
    } on TimeoutException {
      throw const ClassifyException('The server took too long to respond.');
    } on FormatException {
      throw const ClassifyException('Unexpected response from the server.');
    } on ClassifyException {
      rethrow;
    } catch (_) {
      throw const ClassifyException(
        'Could not reach the model API. Check that api.py is running and that '
        'the API URL in app_config.dart is correct.',
      );
    }
  }

  /// Classify an uploaded image (meme). [bytes] are the raw image bytes and
  /// [filename] is used for the multipart part. The server OCRs the image then
  /// classifies the extracted text.
  Future<Prediction> classifyImage(List<int> bytes, String filename) async {
    if (bytes.isEmpty) {
      throw const ClassifyException('Please choose an image first.');
    }
    try {
      final req = http.MultipartRequest('POST', _url('/predict-image'))
        ..files.add(http.MultipartFile.fromBytes('image', bytes, filename: filename));

      final streamed = await req.send().timeout(const Duration(seconds: 60));
      final res = await http.Response.fromStream(streamed);
      final body = jsonDecode(res.body) as Map<String, dynamic>;

      if (res.statusCode == 200) {
        return Prediction.fromJson(body);
      }
      if (res.statusCode == 503) {
        throw const ClassifyException(
          'The model is not loaded on the server. Train/place the model files, then restart api.py.',
        );
      }
      throw ClassifyException(
        (body['error'] ?? 'Request failed (${res.statusCode}).').toString(),
      );
    } on TimeoutException {
      throw const ClassifyException(
        'The server took too long — OCR on the first image can be slow while models download.',
      );
    } on FormatException {
      throw const ClassifyException('Unexpected response from the server.');
    } on ClassifyException {
      rethrow;
    } catch (_) {
      throw const ClassifyException(
        'Could not reach the model API. Check that api.py is running and the API URL is correct.',
      );
    }
  }

  /// Simple connectivity check against `/health`.
  Future<bool> healthy() async {
    try {
      final res =
          await http.get(_url('/health')).timeout(const Duration(seconds: 8));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

class ClassifyException implements Exception {
  final String message;
  const ClassifyException(this.message);
  @override
  String toString() => message;
}
