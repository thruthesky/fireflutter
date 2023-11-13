import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'activity_log.g.dart';

@JsonSerializable()
class ActivityLog {
  final String id;
  final String uid;
  final String? otherUid;
  final String? postId;
  final String? commentId;
  final String? roomId;
  final String type;
  final String action;

  @FirebaseDateTimeConverter()
  final DateTime createdAt;

  ActivityLog({
    required this.id,
    required this.uid,
    this.otherUid,
    this.postId,
    this.commentId,
    this.roomId,
    required this.type,
    required this.action,
    required this.createdAt,
  });

  factory ActivityLog.fromDocumentSnapshot(DocumentSnapshot doc) {
    return ActivityLog.fromJson({
      ...doc.data() as Map<String, dynamic>,
      'id': doc.id,
    });
  }

  factory ActivityLog.fromJson(Map<String, dynamic> json) =>
      _$ActivityLogFromJson(json);
  Map<String, dynamic> toJson() => _$ActivityLogToJson(this);

  static Future<DocumentReference> create({
    String? otherUid,
    String? postId,
    String? commentId,
    String? roomId,
    required String type,
    required String action,
  }) async {
    return await activityLogCol.add({
      'uid': myUid,
      'type': type,
      'action': action,
      'createdAt': FieldValue.serverTimestamp(),
      if (otherUid != null) 'otherUid': otherUid,
      if (postId != null) 'postId': postId,
      if (commentId != null) 'commentId': commentId,
      if (roomId != null) 'roomId': roomId,
    });
  }
}
