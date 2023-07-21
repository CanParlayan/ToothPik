import 'dart:io';
import 'dart:convert';
import 'package:dentalrecognitionproject/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _loading = true;
  late File _image;
  List<Predictions> _output = []; // Initialize as an empty list
  ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future classifyImage(File image) async {
    setState(() {
      _loading = true;
    });

    const url =
        'https://dentalprediction-prediction.cognitiveservices.azure.com/customvision/v3.0/Prediction/b874109f-ffeb-428f-a30b-a9db47b75f26/classify/iterations/Iteration1/image';
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
      print(response.body);
      var data = jsonDecode(response.body);
      List<dynamic> predictionsJson = data['predictions'];

      List<Predictions> predictions = predictionsJson
          .map((json) => Predictions.fromJson(json))
          .toList(); // Convert JSON data to Predictions objects
      setState(() {
        _output = predictions;
        _loading = false;
      });
    } else {
      // Handle error here
      print('Failed with status ${response.statusCode}');
      setState(() {
        _loading = false;
      });
    }
  }

  pickImage() async {
    var image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return null;

    setState(() {
      _image = File(image.path);
    });
    classifyImage(_image);
  }

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
                    ? const LoadingWidget()
                    : Column(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.width * 0.5,
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.file(
                                _image,
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
                              'The teeth has : ${_output.isNotEmpty ? _output[0].tagName : ""}',
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
                      ),
              ),
              Column(
                children: [
                  GestureDetector(
                    onTap: pickImage,
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
                  // Remove the GestureDetector for "Pick From Gallery"
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DentalRec {
  String? id;
  String? project;
  String? iteration;
  String? created;
  List<Predictions>? predictions;

  DentalRec(
      {this.id, this.project, this.iteration, this.created, this.predictions});

  DentalRec.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    project = json['project'];
    iteration = json['iteration'];
    created = json['created'];
    if (json['predictions'] != null) {
      predictions = <Predictions>[];
      json['predictions'].forEach((v) {
        predictions!.add(Predictions.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['project'] = project;
    data['iteration'] = iteration;
    data['created'] = created;
    if (predictions != null) {
      data['predictions'] = predictions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Predictions {
  double? probability;
  String? tagId;
  String? tagName;

  Predictions({this.probability, this.tagId, this.tagName});

  Predictions.fromJson(Map<String, dynamic> json) {
    probability = json['probability'];
    tagId = json['tagId'];
    tagName = json['tagName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['probability'] = probability;
    data['tagId'] = tagId;
    data['tagName'] = tagName;
    return data;
  }
}
