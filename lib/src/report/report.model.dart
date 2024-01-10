import 'package:firebase_database/firebase_database.dart';
import 'package:fireship/fireship.dart';

class ReportModel {
  String? otherUserUid;
  String? chatRoomId;
  String reason;
  final int createdAt;
  ReportModel({
    required this.otherUserUid,
    required this.chatRoomId,
    required this.reason,
    required this.createdAt,
  });
  factory ReportModel.fromJson(Map<dynamic, dynamic> json) {
    return ReportModel(
      otherUserUid: json['otherUserUid'],
      chatRoomId: json['chatRoomId'],
      reason: json['reason'] ?? '',
      createdAt: json['createdAt'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'otherUserUid': otherUserUid,
      'chatRoomId': chatRoomId,
      'reason': reason,
      'createdAt': createdAt,
    };
  }

  @override
  String toString() {
    return 'ReportModel(otherUserUid: $otherUserUid, chatRoomId: $chatRoomId, reason: $reason, createdAt: $createdAt)';
  }

  static Future<void> create({
    String? otherUserUid,
    String? chatRoomId,
    String reason = '',
  }) async {
    return await Ref.reports.child(myUid!).child(otherUserUid ?? chatRoomId!).set({
      'reason': reason,
      'otherUserUid': otherUserUid,
      'chatRoomId': chatRoomId,
      'createdAt': ServerValue.timestamp,
    });
  }
}
