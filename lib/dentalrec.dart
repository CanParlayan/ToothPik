import 'prediction.dart';

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
