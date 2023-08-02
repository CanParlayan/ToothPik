import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'classify.dart';
import 'info_screen.dart';
import 'prediction.dart';

class HomeViewModel extends GetxController {
  final ImagePicker _picker = ImagePicker();
  final RxBool _loading = false.obs;
  final Rx<File?> _image = Rx<File?>(null);
  final RxList<Predictions> _output = RxList<Predictions>([]);
  final RxString _dialogResultText = RxString('');
  final RxBool _isDialogVisible = RxBool(false);
  final RxBool _pinchToZoomOverlayVisible = false.obs;
  final RxString resultText = ''.obs;
  bool get loading => _loading.value;
  File? get image => _image.value;
  List<Predictions> get output => _output.toList();
  String get dialogResultText => _dialogResultText.value;
  bool get isDialogVisible => _isDialogVisible.value;
  bool get pinchToZoomOverlayVisible => _pinchToZoomOverlayVisible.value;

  @override
  void onInit() {
    super.onInit();
    _loading.value = false;
    _image.value = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showInfoScreenIfNeeded();
    });
  }
  void setPinchToZoomOverlayVisible(bool value) {
    _pinchToZoomOverlayVisible.value = value;
  }
  Future<void> showInfoScreenIfNeeded() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool shouldShowInfoScreen = prefs.getBool('showInfoScreen') ?? true;

    if (shouldShowInfoScreen) {
      Get.dialog(const InfoScreen());
    }
  }

  Future<void> classifyImage(File image) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      Get.dialog(
        AlertDialog(
          title: Text('err'.tr),
          content: Text('internet'.tr),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('ok'.tr),
            ),
          ],
        ),
        barrierDismissible: false,
      );
      return;
    }
    _loading.value = true;
    ImageClassifier imageClassifier = ImageClassifier();

    try {
      List<Predictions> predictions = await imageClassifier.classify(image);

      _output.assignAll(predictions);

      bool containsTeeth = _output.any((prediction) =>
      prediction.tagName == 'teeth' && prediction.probability! > 0.5);

      if (!containsTeeth) {
        Get.dialog(
          AlertDialog(
            title: Text('noTeeth'.tr),
            content: Text('pTakePhoto'.tr),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text('ok'.tr),
              ),
            ],
          ),
          barrierDismissible: false,
        );
      } else {

        Map<String, double> dentalIllnessData = await imageClassifier.checkForDentalIllness(image);
        List<String> detectedIllnesses = [];

        bool hasCalculus = dentalIllnessData.entries.any((entry) =>
        entry.key == 'calculus' && entry.value > 0.47);
        if (hasCalculus) {
          detectedIllnesses.add("calculusRes".tr);
        }

        bool isHealthy = dentalIllnessData.entries.any((entry) =>
        entry.key == 'healthy' && entry.value > 0.75);
        if (isHealthy) {
          // Handle the case when the person is healthy separately
          _dialogResultText.value = "healthyRes".tr;
          resultText.value = _dialogResultText.value;
        } else {
          bool hasMouthUlcer = dentalIllnessData.entries.any((entry) =>
          entry.key == 'mouth ulcer' && entry.value > 0.48);
          if (hasMouthUlcer) {
            detectedIllnesses.add("ulcerRes".tr);
          }

          bool hasToothDecay = dentalIllnessData.entries.any((entry) =>
          entry.key == 'tooth decay' && entry.value > 0.24);
          if (hasToothDecay) {
            detectedIllnesses.add("decayRes".tr);
          }

          if (detectedIllnesses.isNotEmpty) {
            String doctor = "doctor".tr;
            if (detectedIllnesses.length > 1) {
              // If there are more than one detected illnesses, add "and" before the last illness.
              String lastIllness = detectedIllnesses.removeLast();
              String joinedIllnesses = detectedIllnesses.join(", ");
              joinedIllnesses = joinedIllnesses.replaceAll(
                  RegExp(r"[.,]"), ""); // Remove dots and spaces
              _dialogResultText.value =
              "$joinedIllnesses ${"and".tr} $lastIllness $doctor";
            } else {
              _dialogResultText.value = "${detectedIllnesses.first} $doctor";
            }
            resultText.value = _dialogResultText.value;
          } else {
            _dialogResultText.value = "notHealthyRes".tr;
            resultText.value = _dialogResultText.value;
          }
        }


        Get.dialog(
          AlertDialog(
            title: Text('teethRes'.tr),
            content: Text(_dialogResultText.value),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text('ok'.tr),
              ),
            ],
          ),
          barrierDismissible: false,
        );
        _pinchToZoomOverlayVisible.value = true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error while processing image classification: $e');
      }
      Get.dialog(
        AlertDialog(
          title: Text('err'.tr),
          content: Text('errMsg'.tr),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('ok'.tr),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    } finally {
      _loading.value = false;
      _isDialogVisible.value = true;
      _pinchToZoomOverlayVisible.value = true;

    }
  }

  Future<void> pickImage(ImageSource imageSource) async {
    var image = await _picker.pickImage(source: imageSource, imageQuality: 50);
    if (image == null) {
      return;
    }

    if (kDebugMode) {
      print("Image Path: ${image.path}");
    } // Add this line to log the image path
    _image.value = File(image.path);
    _loading.value = true;

    try {
      await classifyImage(_image.value!);
    } catch (e) {
        if (kDebugMode) {
          print('Error while picking image: $e');
        }
      Get.dialog(
        AlertDialog(
          title: Text('err'.tr),
          content: Text('errMsg'.tr),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('ok'.tr),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    } finally {
      _loading.value = false;
    }
  }


  void changeLanguage(String languageCode, String? countryCode) {
    Locale locale = Locale(languageCode, countryCode);
    Get.updateLocale(locale);
  }

  void resetResultTextAndPickImage(ImageSource source) {
    resetResultTextAndPinchToZoomOverlay();
    pickImage(source);
  }
  void resetResultTextAndPinchToZoomOverlay() {
    _dialogResultText.value = '';
    _pinchToZoomOverlayVisible.value = false;
  }
}
