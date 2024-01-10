import 'package:firebase_database/firebase_database.dart';
import 'package:fireship/fireship.dart';

class ReportModel {
  final String otherUserUid;
  final String reason;
  final int createdAt;
  ReportModel({
    required this.otherUserUid,
    required this.reason,
    required this.createdAt,
  });
  factory ReportModel.fromJson(Map<dynamic, dynamic> json) {
    return ReportModel(
      otherUserUid: json['otherUserUid'] as String,
      reason: json['reason'] as String,
      createdAt: json['createdAt'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'otherUserUid': otherUserUid,
      'reason': reason,
      'createdAt': createdAt,
    };
  }

  @override
  String toString() {
    return 'ReportModel(otherUserUid: $otherUserUid, reason: $reason, createdAt: $createdAt)';
  }

  static Future<void> create({
    required String otherUserUid,
    String reason = '',
  }) async {
    return await Ref.reports.child(myUid!).child(otherUserUid).set({
      'reason': reason,
      'otherUserUid': otherUserUid,
      'createdAt': ServerValue.timestamp,
    });
  }
}
