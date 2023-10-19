import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/model/activity_log/activity_log.dart';
import 'package:fireflutter/src/model/activity_log/log_type.dart';

/// Alias of [ActivityLog.create()]
///
/// Use this method to save activity log.
Future<DocumentReference?> activityLog({
  String? otherUid,
  String? postId,
  String? commentId,
  String? roomId,
  required String type,
  required String action,
}) async {
  if (ActivityLogService.instance.enableActivityLog == false) return null;
  return await ActivityLog.create(
    otherUid: otherUid,
    postId: postId,
    commentId: commentId,
    roomId: roomId,
    type: type,
    action: action,
  );
}

/// *********** User Activity Log ***********

Future<DocumentReference?> activityLogAppStart() {
  return activityLog(
    type: Log.type.user,
    action: Log.user.startApp,
  );
}

Future<DocumentReference?> activityLogSignin() {
  return activityLog(
    type: Log.type.user,
    action: Log.user.signin,
  );
}

Future<DocumentReference?> activityLogSignout() {
  return activityLog(
    type: Log.type.user,
    action: Log.user.signout,
  );
}

Future<DocumentReference?> activityLogUserResign() {
  return activityLog(
    type: Log.type.user,
    action: Log.user.resign,
  );
}

Future<DocumentReference?> activityLogUserCreate() {
  return activityLog(
    type: Log.type.user,
    action: Log.user.create,
  );
}

Future<DocumentReference?> activityLogUserUpdate() {
  return activityLog(
    type: Log.type.user,
    action: Log.user.update,
  );
}

Future<DocumentReference?> activityLogUserLike({required String otherUid, required bool isLiked}) {
  return activityLog(
    otherUid: otherUid,
    type: Log.type.user,
    action: isLiked == true ? Log.user.like : Log.user.unlike,
  );
}

Future<DocumentReference?> activityLogUserFollow({required String otherUid, required bool isFollow}) {
  return activityLog(
    otherUid: otherUid,
    type: Log.type.user,
    action: isFollow == true ? Log.user.follow : Log.user.unfollow,
  );
}

Future<DocumentReference?> activityLogUserViewProfile({required String otherUid}) {
  return activityLog(
    otherUid: otherUid,
    type: Log.type.user,
    action: Log.user.viewProfile,
  );
}

/// *********** Post Activity Log ***********

Future<DocumentReference?> activityLogPostCreate({
  required String postId,
}) async {
  return await activityLog(
    postId: postId,
    type: Log.type.post,
    action: Log.post.create,
  );
}

Future<DocumentReference?> activityLogPostUpdate({
  required String postId,
}) async {
  return await activityLog(
    postId: postId,
    type: Log.type.post,
    action: Log.post.update,
  );
}

Future<DocumentReference?> activityLogPostDelete({
  required String postId,
}) async {
  return await activityLog(
    postId: postId,
    type: Log.type.post,
    action: Log.post.delete,
  );
}

Future<DocumentReference?> activityLogPostLike({
  required String postId,
  required bool isLiked,
}) async {
  return await activityLog(
    postId: postId,
    type: Log.type.post,
    action: isLiked == true ? Log.post.like : Log.post.unlike,
  );
}

/// *********** Comment Activity Log ***********

/// Add post id to know all the activities of a post
Future<DocumentReference?> activityLogCommentCreate({
  required String postId,
  required String commentId,
}) async {
  return await activityLog(
    postId: postId,
    commentId: commentId,
    type: Log.type.comment,
    action: Log.comment.create,
  );
}

Future<DocumentReference?> activityLogCommentUpdate({
  required String commentId,
}) async {
  return await activityLog(
    commentId: commentId,
    type: Log.type.comment,
    action: Log.comment.update,
  );
}

Future<DocumentReference?> activityLogCommentDelete({
  required String commentId,
}) async {
  return await activityLog(
    commentId: commentId,
    type: Log.type.comment,
    action: Log.comment.delete,
  );
}

Future<DocumentReference?> activityLogCommentLike({
  required String commentId,
  required bool isLiked,
}) async {
  return await activityLog(
    commentId: commentId,
    type: Log.type.comment,
    action: isLiked == true ? Log.comment.like : Log.comment.unlike,
  );
}

/// *********** Chat Activity Log ***********

Future<DocumentReference?> activityLogChatOpen({required String roomId}) {
  return activityLog(
    roomId: roomId,
    type: Log.type.chat,
    action: Log.chat.open,
  );
}

/// *********** Feed Activity Log ***********

Future<DocumentReference?> activityLogFeedFollow({required String otherUid, required bool isFollow}) {
  return activityLog(
    otherUid: otherUid,
    type: Log.type.feed,
    action: isFollow == true ? Log.feed.follow : Log.feed.unfollow,
  );
}

// *********** Share Activity Log ***********

Future<DocumentReference?> activityLogShare({required String id, required String type}) {
  return activityLog(
    type: Log.type.user,
    action: Log.user.share,
    postId: type == Log.type.post ? id : null,
    commentId: type == Log.type.comment ? id : null,
    otherUid: type == Log.type.user ? id : null,
  );
}
