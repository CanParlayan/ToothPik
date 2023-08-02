import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'prediction.dart';

abstract class ImageClassification {
  Future<List<Predictions>> classify(File image);

  Future<Map<String, double>> checkForDentalIllness(File image);
}

class ImageClassifier implements ImageClassification {
  ImageClassifier();

  @override
  Future<List<Predictions>> classify(File image) async {
    const url =
        'https://dentalprediction-prediction.cognitiveservices.azure.com/customvision/v3.0/Prediction/d7ea90e0-a0a9-4b6f-8362-e706d522e20f/classify/iterations/Iteration1/image';
    final headers = {
      'Prediction-Key': '6c41e9fb16f64bf39c334fb6ae1761bc',
      'Content-Type': 'application/octet-stream',
    };

    var bytes = await image.readAsBytes();
    var response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: bytes,
    );
    response.body;
    response.statusCode;
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      List<dynamic> predictionsJson = data['predictions'];

      List<Predictions> predictions =
          predictionsJson.map((json) => Predictions.fromJson(json)).toList();

      return predictions;
    } else {
      throw Exception('Teeth identification failed');
    }
  }

  @override
  Future<Map<String, double>> checkForDentalIllness(File image) async {
    const dentalUrl =
        'https://dentalprediction-prediction.cognitiveservices.azure.com/customvision/v3.0/Prediction/26e37ef9-75e0-4e14-818a-e3dc13b80a9d/classify/iterations/Iteration5/image';
    final dentalHeaders = {
      'Prediction-Key': '6c41e9fb16f64bf39c334fb6ae1761bc',
      'Content-Type': 'application/octet-stream',
    };

    var dentalBytes = await image.readAsBytes();
    var dentalResponse = await http
        .post(
      Uri.parse(dentalUrl),
      headers: dentalHeaders,
      body: dentalBytes,
    )
        .timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw TimeoutException(
            'The connection has timed out, please try again!');
      },
    );
    dentalResponse.body;
    dentalResponse.statusCode;
    if (dentalResponse.statusCode == 200) {
      var dentalData = jsonDecode(dentalResponse.body);
      List<dynamic> predictionsJson = dentalData['predictions'];

      Map<String, double> dentalPredictions = {};

      for (var prediction in predictionsJson) {
        String tagName = prediction['tagName'];
        double probability = prediction['probability'];
        dentalPredictions[tagName] = probability;
      }

      return dentalPredictions;
    } else {
      throw Exception('Failed to check for dental illness');
    }
  }
}
