import 'dart:io';
import 'dart:convert';
import 'package:dentalrecognitionproject/prediction.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _loading = false;
  File? _image; // Nullable type
  List<Predictions> _output = []; // Initialize as an empty list
  ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loading = false;
    _image = null;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> classifyImage(BuildContext context, File image) async {
    const url =
        'https://dentalprediction-prediction.cognitiveservices.azure.com/customvision/v3.0/Prediction/1b465330-89d1-4acf-90c3-a64f76114ad3/detect/iterations/Iteration2/image';
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

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print(response.body);
      }
      var data = jsonDecode(response.body);
      List<dynamic> predictionsJson = data['predictions'];

      List<Predictions> predictions = predictionsJson
          .map((json) => Predictions.fromJson(json))
          .toList(); // Convert JSON data to Predictions objects

      setState(() {
        _output = predictions;
        _loading = false; // Set _loading to false after prediction is completed
      });
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
        // If teeth are detected, check for cavities
        bool hasCavity =
            _output.any((prediction) => prediction.tagName == 'cavity');

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
      }
    } else {
      // Handle error here
      if (kDebugMode) {
        print('Failed with status ${response.statusCode}');
      }
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> pickImage(ImageSource imageSource) async {
    var image = await picker.pickImage(source: imageSource);
    if (image == null)
      return; // Handle the case when the user cancels image selection

    setState(() {
      _image = File(image.path);
      _loading = true;
    });

    classifyImage(context, _image!).then((_) {
      setState(() {
        _loading = false;
      });
    }).catchError((error) {
      if (kDebugMode) {
        print('Error during prediction: $error');
      }
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        centerTitle: true,
        title: const Text(
          'Dental Recognition',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 23,
          ),
        ),
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
                              // ignore: unnecessary_null_comparison
                              if (_output != null && _output.isNotEmpty)
                                Text(
                                  'The teeth has : ${_output.isNotEmpty ? _output[1].tagName : ""}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              const Divider(
                                height: 25,
                                thickness: 1,
                              ),
                            ],
                          )
                        : const Text(
                            'No image selected'), // Show "No image selected" message
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
                      child: const Text(
                        'Take A Photo',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: () => pickImage(ImageSource
                        .gallery), // Call the new function for gallery image selection
                    child: Container(
                      width: MediaQuery.of(context).size.width - 200,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 17),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Text(
                        'Pick From Gallery',
                        style: TextStyle(color: Colors.white, fontSize: 16),
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
}