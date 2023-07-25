import 'package:dentalrecognitionproject/prediction.dart';
import 'dart:io';
abstract class ImageClassification {
  Future<List<Predictions>> classify(File image);
  Future<bool> checkForCavity(File image);
}