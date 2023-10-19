import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/src/model/activity_log/activity_log.dart';

/// Alias of [ActivityLog.create()]
///
/// Use this method to save activity log.
Future<DocumentReference> activityLog({
  String? otherUid,
  String? postId,
  String? commentId,
  required String type,
  required String action,
}) async {
  return await ActivityLog.create(
    otherUid: otherUid,
    postId: postId,
    commentId: commentId,
    type: type,
    action: action,
  );
}

/// Add post id to know all the activities of a post
Future<DocumentReference> activityLogCommentCreate({
  required String postId,
  required String commentId,
}) async {
  return await ActivityLog.create(
    postId: postId,
    commentId: commentId,
    type: 'comment',
    action: 'create',
  );
}

Future<DocumentReference> activityLogCommentUpdate({
  required String commentId,
}) async {
  return await ActivityLog.create(
    commentId: commentId,
    type: 'comment',
    action: 'updated',
  );
}
