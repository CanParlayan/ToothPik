import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'classify.dart';
import 'dental_illness_detector.dart';
import 'dialog_helper.dart';
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
  final dentalIllnessDetector = DentalIllnessDetector({});
  RxString resultText = ''.obs;

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
      DialogHelper.showNoInternetDialog(Get.context!);
      return;
    }
    _loading.value = true;
    ImageClassifier imageClassifier = ImageClassifier();

    try {
      List<Predictions> predictions = await imageClassifier.classify(image);

      _output.assignAll(predictions);

      bool containsTeeth = _output.any((prediction) =>
          prediction.tagName == 'teeth' && prediction.probability! > 0.5);
      if (kDebugMode) {
        print('Predictions: $_output');
      }
      if (kDebugMode) {
        print('Contains Teeth: $containsTeeth');
      }
      if (!containsTeeth) {
        DialogHelper.showNoTeethDialog(Get.context!);
      } else {
        final Map<String, String> illnessTranslations = {
          'calculus': "calculusRes".tr,
          'healthy': "healthyRes".tr,
          'mouth ulcer': "ulcerRes".tr,
          'tooth decay': "decayRes".tr,
        };
        Map<String, double> dentalIllnessData =
            await imageClassifier.checkForDentalIllness(image);
        DentalIllnessDetector detector =
            DentalIllnessDetector(dentalIllnessData);
        detector.detectIllnesses(illnessTranslations);
        if (detector.hasDetectedIllnesses()) {
          String dialogText = detector.dialogResultText;
          DialogHelper.showTeethDialog(Get.context!, dialogText);
          resultText.value = detector.dialogResultText;
        } else {
          DialogHelper.showNoIllnessDialog(Get.context!);
          resultText.value = detector.dialogResultText;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error while processing image classification: $e');
      }
      DialogHelper.showErrorDialog(Get.context!);
      resultText.value = "";
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
    }
    _image.value = File(image.path);
    _loading.value = true;

    try {
      await classifyImage(_image.value!);
    } catch (e) {
      if (kDebugMode) {
        print('Error while picking image: $e');
      }
      DialogHelper.showDeveloperErrorMessage(Get.context!);
    } finally {
      _loading.value = false;
    }
  }

  void changeLanguage(String languageCode, String? countryCode) {
    Locale locale = Locale(languageCode, countryCode);
    Get.updateLocale(locale);
    resultText.value = "";
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
