import 'package:fireflutter/fireflutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  String id;
  String target;
  String targetId;
  String uid;
  String reason;
  Timestamp? timestamp;

  ReportModel({
    required this.id,
    required this.target,
    required this.targetId,
    required this.uid,
    required this.reason,
    required this.timestamp,
  });

  factory ReportModel.fromJson(Json json, {String? id}) {
    Timestamp? _ts = json['timestamp'] is int
        ? Timestamp.fromMillisecondsSinceEpoch(json['timestamp'] * 1000)
        : json['timestamp'];

    return ReportModel(
      target: json['target'] ?? '',
      targetId: json['targetId'] ?? '',
      uid: json['uid'] ?? '',
      reason: json['reason'] ?? '',
      id: id ?? json['id'],
      timestamp: _ts,
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
