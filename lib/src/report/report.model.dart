import 'package:firebase_database/firebase_database.dart';
import 'package:fireship/fireship.dart';

class ReportModel {
  String? otherUserUid;
  String? chatRoomId;
  String? postId;
  String? commentId;
  String reason;
  final int createdAt;
  ReportModel({
    required this.otherUserUid,
    required this.chatRoomId,
    required this.postId,
    required this.commentId,
    required this.reason,
    required this.createdAt,
  });
  factory ReportModel.fromJson(Map<dynamic, dynamic> json) {
    return ReportModel(
      otherUserUid: json['otherUserUid'],
      chatRoomId: json['chatRoomId'],
      postId: json['postId'],
      commentId: json['commentId'],
      reason: json['reason'] ?? '',
      createdAt: json['createdAt'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'otherUserUid': otherUserUid,
      'chatRoomId': chatRoomId,
      'postId': postId,
      'commentId': commentId,
      'reason': reason,
      'createdAt': createdAt,
    };
  }

  @override
  String toString() {
    return 'ReportModel(otherUserUid: $otherUserUid, chatRoomId: $chatRoomId, postId: $postId, commentId: $commentId, reason: $reason, createdAt: $createdAt)';
  }

  static Future<void> create({
    String? otherUserUid,
    String? chatRoomId,
    String? postId,
    String? commentId,
    String reason = '',
  }) async {
    return await Ref.reports
        .child(myUid!)
        .child(otherUserUid ?? chatRoomId ?? postId ?? commentId!)
        .set({
      'reason': reason,
      'otherUserUid': otherUserUid,
      'postId': postId,
      'commentId': commentId,
      'chatRoomId': chatRoomId,
      'createdAt': ServerValue.timestamp,
    });
  }
}
