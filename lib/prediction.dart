import 'dart:ui';

class Predictions {
  double? probability;
  String? tagId;
  String? tagName;
  double? left;
  double? top;
  double? width;
  double? height;
  Rect? boundingBox;

  Predictions(
      {this.probability,
      this.tagId,
      this.tagName,
      this.left,
      this.top,
      this.width,
      this.height});
  Predictions.fromJson(Map<String, dynamic> json) {
    probability = json['probability'];
    tagId = json['tagId'];
    tagName = json['tagName'];
    left = json['left'] ?? 0;
    top = json['top'] ?? 0;
    width = json['width'] ?? 0;
    height = json['height'] ?? 0;
    boundingBox = Rect.fromLTWH(left!, top!, width!, height!);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['probability'] = probability;
    data['tagId'] = tagId;
    data['tagName'] = tagName;
    return data;
  }
}
