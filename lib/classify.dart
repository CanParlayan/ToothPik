import 'package:dentalrecognitionproject/prediction.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'abstractimageclassifier.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:connectivity/connectivity.dart';
import 'package:dentalrecognitionproject/classify.dart';
import 'package:dentalrecognitionproject/infoscreen.dart';
import 'package:dentalrecognitionproject/prediction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
class ImageClassifier implements ImageClassification {
  final BuildContext context;

  ImageClassifier(this.context);
  @override
  Future<List<Predictions>> classify(File image) async {
    const url =
        'https://dentalprediction-prediction.cognitiveservices.azure.com/customvision/v3.0/Prediction/1b465330-89d1-4acf-90c3-a64f76114ad3/detect/iterations/Iteration3/image';
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('err'.tr),
        content: Text('internet'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('ok'.tr),
          ),
        ],
      ),
    );
    if (response.statusCode == 200) {
      print(response.body);
      var data = jsonDecode(response.body);
      List<dynamic> predictionsJson = data['predictions'];

      List<Predictions> predictions = predictionsJson
          .map((json) => Predictions.fromJson(json))
          .toList(); // Convert JSON data to Predictions objects

      return predictions;
    } else {
      showDialog(
        context: context, // You'll need to pass the app's context to this class
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to classify image'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          );
        },
      );

      throw Exception('Failed to classify image');
    }
  }

  @override
  Future<bool> checkForCavity(File image) async {
    const cavityUrl =
        'https://dentalprediction-prediction.cognitiveservices.azure.com/customvision/v3.0/Prediction/b874109f-ffeb-428f-a30b-a9db47b75f26/classify/iterations/Iteration1/image';
    final cavityHeaders = {
      'Prediction-Key': '6c41e9fb16f64bf39c334fb6ae1761bc',
      'Content-Type': 'application/octet-stream',
    };

    var cavityBytes = await image.readAsBytes();
    var cavityResponse = await http.post(
      Uri.parse(cavityUrl),
      headers: cavityHeaders,
      body: cavityBytes,
    );

    if (cavityResponse.statusCode == 200) {
      var cavityData = jsonDecode(cavityResponse.body);
      bool hasCavity = cavityData['hasCavity'] ?? false;
      return hasCavity;
    } else {
      showDialog(
        context: context, // You'll need to pass the app's context to this class
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to check for cavity'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          );
        },
      );

      throw Exception('Failed to check for cavity');
    }
  }
}