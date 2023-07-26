import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'classify.dart';
import 'info_screen.dart';
import 'prediction.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Add the following variables
  bool _loading = false;
  File? _image; // Nullable type
  List<Predictions> _output = []; // Initialize as an empty list
  ImagePicker picker = ImagePicker();
  String _resultText = ''; // Initialize result text as empty
  bool _pinchToZoomOverlayVisible = false; // New flag variable

  @override
  void initState() {
    super.initState();
    _loading = false;
    _image = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showInfoScreenIfNeeded();
    });
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

  Future<void> classifyImage(BuildContext context, File image) async {
    // Check for internet connectivity
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // Show an error dialog if there's no internet connection
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
      return;
    }
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

    // Check if teeth are detected in the image
    bool containsTeeth =
        _output.any((prediction) => prediction.tagName == 'teeth');

    if (!containsTeeth) {
      // If teeth are not detected, show a message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('noTeeth'.tr),
          content: Text('pTakePhoto'.tr),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('ok'.tr),
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

      try {
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

          var cavityData = jsonDecode(cavityResponse.body);
          bool hasCavity = cavityData['hasCavity'] ?? false;

          setState(() {
            _resultText = hasCavity ? 'hasCavity'.tr : 'hasNoCavity'.tr;
          });

          // Show the result to the user
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('teethRes'.tr),
              content: Text(hasCavity ? 'hasCavity'.tr : 'hasNoCavity'.tr),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('ok'.tr),
                ),
              ],
            ),
          );
          _pinchToZoomOverlayVisible = true;
        } else {
          // Handle error from the cavity detection API here
          if (kDebugMode) {
            print(
                'Failed to check for cavity with status ${cavityResponse.statusCode}');
          }

          String errorMessage;
          if (cavityResponse.statusCode == 400) {
            errorMessage = 'API not available.';
          } else {
            errorMessage = 'An error occurred. Please try again later.';
          }

          // Show the error message to the user
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('err'.tr),
              content: Text(errorMessage),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('ok'.tr),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        // Handle other exceptions that may occur
        if (kDebugMode) {
          print('Error while processing cavity detection: $e');
        }

        // Show a generic error message to the user
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('err'.tr),
            content: Text('errMsg'.tr),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('ok'.tr),
              ),
            ],
          ),
        );
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

    classifyImage(context, _image!).then((_) {
      setState(() {
        _loading = false;
      });
    });
  }

  void _changeLanguage(String languageCode, String? countryCode) {
    Locale locale = Locale(languageCode, countryCode);
    Get.updateLocale(locale);

    // Call setState to trigger a rebuild of the widget and update the displayed text
    setState(() {
      _resultText = _output.isEmpty
          ? '' // If _output is empty, keep the resultText empty
          : _output[0].tagName == 'teeth'
              ? 'hasNoCavity'.tr
              : 'hasCavity'.tr;
    });
  }

  void _resetResultTextAndPickImage(ImageSource source) {
    setState(() {
      _resultText = '';
    });
    pickImage(source);
  }

  Widget _buildInteractiveViewer() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: GestureDetector(
          onTap: () {
            setState(() {
              _pinchToZoomOverlayVisible =
                  false; // Hide the overlay when the image is tapped
            });
          },
          child: Stack(
            children: [
              Center(
                child: _loading
                    ? const CircularProgressIndicator()
                    : _image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: GestureDetector(
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                setState(() {
                                  _pinchToZoomOverlayVisible = false;
                                });
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: InteractiveViewer(
                                  maxScale: 7.0,
                                  child: Image.file(
                                    _image!,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              'noImage'.tr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
              ),
              if (_pinchToZoomOverlayVisible)
                _buildPinchToZoomOverlay(BorderRadius.circular(50)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinchToZoomOverlay(BorderRadius borderRadius) {
    return Positioned.fill(
      child: AbsorbPointer(
        absorbing: _loading || !_pinchToZoomOverlayVisible,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _pinchToZoomOverlayVisible = false; // Hide the overlay
            });
          },
          child: ClipRRect(
            borderRadius: borderRadius, // Use the passed border radius
            child: Center(
              child: Text(
                'zoom'.tr,
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonsRow() {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () =>
                        _resetResultTextAndPickImage(ImageSource.camera),
                    child: Container(
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
                ),
                const SizedBox(width: 16),
                Flexible(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () =>
                        _resetResultTextAndPickImage(ImageSource.gallery),
                    child: Container(
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
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Text(
              _resultText.tr, // Display the result text
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Check the screen width to determine the layout
              if (constraints.maxWidth < 600) {
                // For smaller screens (width < 600), use a single-column layout
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildInteractiveViewer(),
                      const SizedBox(height: 30),
                      _buildButtonsRow(),
                      const SizedBox(height: 30),
                      Text(
                        _resultText.tr, // Display the result text
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                );
              } else {
                // For larger screens (width >= 600), use a two-column layout
                return Row(
                  children: [
                    Expanded(child: _buildInteractiveViewer()),
                    const SizedBox(width: 30),
                    Expanded(child: _buildButtonsRow()),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
