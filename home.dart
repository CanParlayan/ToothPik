import 'dart:io';
import 'dart:convert';
import 'package:flutter_svg/svg.dart';

import 'classify.dart';
import 'prediction.dart';
import 'info_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'app_translations.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _loading = false;
  File? _image;
  List<Predictions> _output = [];
  ImagePicker picker = ImagePicker();

  @override
  void initState() {
    _loading = false;
    _image = null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showInfoScreenIfNeeded();
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> showInfoScreenIfNeeded() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool shouldShowInfoScreen = prefs.getBool('showInfoScreen') ?? true;

    if (shouldShowInfoScreen) {
      // Show the info screen when the app is opened

      showDialog(
        context: context,
        builder: (context) => const InfoScreen(),
      );
    }
  }

  Future<void> classifyImage(File image) async {
    setState(() {
      _loading = true;
    });

    // Create an instance of the image classifier
    ImageClassifier imageClassifier = ImageClassifier();

    // Perform image classification
    List<Predictions> predictions = await imageClassifier.classify(image);

    setState(() {
      _output = predictions;
      _loading = false;
    });
    if (!context.mounted) return;
    // Check if teeth are detected in the image
    bool containsTeeth =
        _output.any((prediction) => prediction.tagName == 'teeth');

    if (!containsTeeth) {
      // If teeth are not detected, show a message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No teeth detected'),
          content: const Text('Please take a photo of your teeth.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
// If teeth are detected, proceed to check for cavities using another API

// Replace the following constant and headers with the ones for the cavity detection API
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
        if (kDebugMode) {
          print(cavityResponse.body);
        }

        if (!context.mounted) return;

        var cavityData = jsonDecode(cavityResponse.body);
        bool hasCavity = cavityData['hasCavity'] ?? false;

// Show the result to the user
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Teeth Classification Result'),
            content: Text(hasCavity
                ? 'Your teeth have a cavity.'
                : 'Your teeth are cavity-free.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
// Handle error from the cavity detection API here
        if (kDebugMode) {
          print(
              'Failed to check for cavity with status ${cavityResponse.statusCode}');
        }
      }
    }
  }

  Future<void> pickImage(ImageSource imageSource) async {
    var image = await picker.pickImage(source: imageSource);
    if (image == null) {
      return; // Handle the case when the user cancels image selection
    }

    setState(() {
      _image = File(image.path);
      _loading = true;
    });

    classifyImage(_image!).then((_) {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        centerTitle: true,
        title: Text(
          'appTitle'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 23,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _changeLanguage('en', 'US'),
            icon: SvgPicture.asset(
              'assets/flags/gb.svg',
              width: 24,
              height: 24,
            ),
          ),
          IconButton(
            onPressed: () => _changeLanguage('tr', ''),
            icon: SvgPicture.asset(
              'assets/flags/tr.svg',
              width: 24,
              height: 24,
            ),
          ),
        ],
      ),
      body: Container(
        color: const Color.fromRGBO(68, 190, 255, 0.8),
        padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 50),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.indigo,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: _loading
                    ? const CircularProgressIndicator()
                    : _image != null
                        ? Column(
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.width * 0.5,
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: Image.file(
                                    _image!,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              const Divider(
                                height: 25,
                                thickness: 1,
                              ),
                              if (_output != null && _output.isNotEmpty)
                                const Divider(
                                  height: 25,
                                  thickness: 1,
                                ),
                            ],
                          )
                        : Text(
                            'noImage'.tr), // Show "No image selected" message
              ),
              Column(
                children: [
                  GestureDetector(
                    onTap: () => pickImage(ImageSource.camera),
                    child: Container(
                      width: MediaQuery.of(context).size.width - 200,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 17),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        'takePhoto'.tr,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: () => pickImage(ImageSource.gallery),
                    // Call the new function for gallery image selection
                    child: Container(
                      width: MediaQuery.of(context).size.width - 200,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 17),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        'pickGallery'.tr,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _changeLanguage(String languageCode, String? countryCode) {
    Locale locale = Locale(languageCode, countryCode);
    Get.updateLocale(locale);
  }
}
