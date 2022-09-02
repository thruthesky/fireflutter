import 'package:fireflutter/fireflutter.dart';

class ReportModel {
  String id;
  String target;
  String targetId;
  String uid;
  String reason;
  int timestamp;

  ReportModel({
    required this.id,
    required this.target,
    required this.targetId,
    required this.uid,
    required this.reason,
    required this.timestamp,
  });

  factory ReportModel.fromJson(Json json, {String? id}) {
    return ReportModel(
      target: json['target'] ?? '',
      targetId: json['targetId'] ?? '',
      uid: json['uid'] ?? '',
      reason: json['reason'] ?? '',
      timestamp: json['timestamp'] ?? 0,
      id: id ?? json['id'],
    );
  }

  @override
  String toString() {
    return '''ReportModel(
      id: $id,
      target: $target,
      targetId: $targetId,
      uid: $uid,
      reason: $reason,
      timestamp: $timestamp,
    );''';
  }
}
