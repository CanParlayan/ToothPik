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
  RxBool _loading = false.obs;
  Rx<File?> _image = Rx<File?>(null);
  RxList<Predictions> _output = RxList<Predictions>([]);
  String _resultText = '';
  RxBool _pinchToZoomOverlayVisible = false.obs;

  void setPinchToZoomOverlayVisible(RxBool value) {
    _pinchToZoomOverlayVisible = value;
  }

  void setLoading(RxBool value) {
    _loading = value;
  }

  void setImage(Rx<File?> value) {
    _image = value;
  }

  void setOutput(RxList<Predictions> value) {
    _output = value;
  }

  void setResultText(String value) {
    _resultText = value;
  }

  bool get loading => _loading.value;

  File? get image => _image.value;

  List<Predictions> get output => _output.toList();

  String get resultText => _resultText;

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
        bool hasCavity = await imageClassifier.checkForCavity(image);

        _resultText = hasCavity ? 'hasCavity'.tr : 'hasNoCavity'.tr;

        Get.dialog(
          AlertDialog(
            title: Text('teethRes'.tr),
            content: Text(_resultText),
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
    }
  }

  Future<void> pickImage(ImageSource imageSource) async {
    var image = await _picker.pickImage(source: imageSource);
    if (image == null) {
      return;
    }

    _image.value = File(image.path);
    _loading.value = true;

    try {
      await classifyImage(_image.value!);
    } finally {
      _loading.value = false;
    }
  }

  void changeLanguage(String languageCode, String? countryCode) {
    Locale locale = Locale(languageCode, countryCode);
    Get.updateLocale(locale);

    _resultText = _output.isEmpty
        ? ''
        : _output[0].tagName == 'teeth'
            ? 'hasNoCavity'.tr
            : 'hasCavity'.tr;
  }

  void resetResultTextAndPickImage(ImageSource source) {
    _resultText = '';
    pickImage(source);
  }
}
