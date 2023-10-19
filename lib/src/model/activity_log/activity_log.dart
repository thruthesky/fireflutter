import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'activity_log.g.dart';

@JsonSerializable()
class ActivityLog {
  final String uid;
  final String? otherUid;
  final String? postId;
  final String? commentId;
  final String type;
  final String action;

  @FirebaseDateTimeConverter()
  final DateTime createdAt;

  ActivityLog({
    required this.uid,
    this.otherUid,
    this.postId,
    this.commentId,
    required this.type,
    required this.action,
    required this.createdAt,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) => _$ActivityLogFromJson(json);

  static Future<DocumentReference> create({
    String? otherUid,
    String? postId,
    String? commentId,
    required String type,
    required String action,
  }) async {
    return await activityLogCol.add({
      'uid': myUid,
      'otherUid': otherUid,
      'postId': postId,
      'commentId': commentId,
      'type': type,
      'action': action,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
