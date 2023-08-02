import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DialogHelper {
  static void showNoInternetDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
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
    );
  }

  static void showNoTeethDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
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
    );
  }

  static void showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
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
    );
  }

  static void showTeethDialog(BuildContext context, String dialogText) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          AlertDialog(
            title: Text('teethRes'.tr),
            content: Text(dialogText),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text('ok'.tr),
              ),
            ],
          ),
    );
  }

  static void showNoIllnessDialog(BuildContext buildContext) {
    showDialog(
      context: buildContext,
      barrierDismissible: false,
      builder: (context) =>
          AlertDialog(
            title: Text('teethRes'.tr),
            content: Text('healthyRes'.tr),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text('ok'.tr),
              ),
            ],
          ),
    );
  }

  static void showDeveloperErrorMessage(BuildContext buildContext) {
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
  }
}
