import 'package:get/get.dart';

class DentalIllnessDetector {
  Map<String, double> dentalIllnessData;
  List<String> detectedIllnesses = [];
  String _dialogResultText = '';
  String get dialogResultText => _dialogResultText;

  DentalIllnessDetector(this.dentalIllnessData);

  void detectIllnesses(Map<String, String> illnessTranslations) {
    bool isHealthy = dentalIllnessData.entries
        .any((entry) => entry.key == 'healthy' && entry.value > 0.58);
    if (isHealthy) {
      _dialogResultText = "healthyRes".tr;
    } else {
      bool hasMouthUlcer = dentalIllnessData.entries
          .any((entry) => entry.key == 'mouth ulcer' && entry.value > 0.44);
      if (hasMouthUlcer) {
        detectedIllnesses.add("ulcerRes".tr);
      }

      bool hasToothDecay = dentalIllnessData.entries
          .any((entry) => entry.key == 'tooth decay' && entry.value > 0.44);
      if (hasToothDecay) {
        detectedIllnesses.add("decayRes".tr);
      }
      bool hasCalculus = dentalIllnessData.entries
          .any((entry) => entry.key == 'calculus' && entry.value > 0.38);
      if (hasCalculus) {
        detectedIllnesses.add("calculusRes".tr);
      }

      String doctor = "doctor".tr;
      if (detectedIllnesses.isNotEmpty) {
        if (detectedIllnesses.length > 1) {
          String lastIllness = detectedIllnesses.removeLast();
          String joinedIllnesses = detectedIllnesses.join(", ");
          joinedIllnesses = joinedIllnesses.replaceAll(RegExp(r"[.,]"), "");
          _dialogResultText =
              "$joinedIllnesses ${"and".tr} $lastIllness $doctor";
        } else {
          _dialogResultText = "${detectedIllnesses.first} $doctor";
        }
      } else if (detectedIllnesses.isEmpty) {
        for (var entry in dentalIllnessData.entries) {
          if (entry.value > 0.1) {
            String illness = entry.key;
            String translatedIllness = illnessTranslations[illness] ?? '';
            if (translatedIllness.isNotEmpty) {
              if (!detectedIllnesses.contains(translatedIllness)) {
                detectedIllnesses.add(translatedIllness);

                bool isWithinRange = dentalIllnessData.entries.any((e) =>
                    e.value >= entry.value - 0.05 &&
                    e.value <= entry.value + 0.05);

                if (isWithinRange) {
                  if (!detectedIllnesses.contains(translatedIllness)) {
                    detectedIllnesses.add(translatedIllness);
                  }
                }
              }
            }
          }
        }
        if (detectedIllnesses.length > 1) {
          String lastIllness = detectedIllnesses.removeLast();
          String joinedIllnesses = detectedIllnesses.join(", ");
          joinedIllnesses = joinedIllnesses.replaceAll(RegExp(r"[.,]"), "");
          _dialogResultText =
              "$joinedIllnesses ${"and".tr} $lastIllness $doctor";
        } else {
          _dialogResultText = "${detectedIllnesses.first} $doctor";
        }
      } else {
        _dialogResultText = "notHealthyRes".tr;
      }
    }
  }

  bool hasDetectedIllnesses() {
    return detectedIllnesses.isNotEmpty;
  }

  List<String> getDetectedIllnesses() {
    return detectedIllnesses;
  }
}
