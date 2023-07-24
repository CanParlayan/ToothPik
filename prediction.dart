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
