import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/model/activity_log/log_type.dart';
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

  factory ActivityLog.fromJson(Map<String, dynamic> json) => _$ActivityLogFromJson(json);
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

  Future<String> get getName async {
    final user = await UserService.instance.get(uid) as User;
    return user.getDisplayName;
  }

  Future<String> get getOtherName async {
    if (otherUid == null) return '';

    final user = await UserService.instance.get(otherUid!) as User;
    return user.getDisplayName;
  }

  Future<String> get getMessage async {
    String name = await getName;
    String otherDisplayName = await getOtherName;

    if (type == Log.type.user) {
      if (action == Log.user.startApp) {
        return '$name started app';
      }
      if (action == Log.user.create) {
        return '$name created an account';
      }
      if (action == Log.user.update) {
        return '$name updated profile';
      }
      if (action == Log.user.resign) {
        return '$name resign account';
      }
      if (action == Log.user.signin) {
        return '$name signed in';
      }
      if (action == Log.user.signout) {
        return '$name signed out';
      }
      if (action == Log.user.like) {
        return '$name liked user $otherDisplayName';
      }
      if (action == Log.user.unlike) {
        return '$name unliked user $otherDisplayName';
      }
      if (action == Log.user.follow) {
        return '$name followed user $otherDisplayName';
      }
      if (action == Log.user.unfollow) {
        return '$name unfollowed user $otherDisplayName';
      }
      if (action == Log.user.viewProfile) {
        return '$name viewed profile of $otherDisplayName';
      }
    }

    if (type == Log.type.post) {
      Post post = await PostService.instance.get(postId!);
      String title = post.title;

      if (action == Log.post.create) {
        return '$name created a post $title';
      }
      if (action == Log.post.update) {
        return '$name updated a post $title';
      }
      if (action == Log.post.delete) {
        return '$name deleted a post $title';
      }
      if (action == Log.post.like) {
        return '$name liked post $title';
      }
      if (action == Log.post.unlike) {
        return '$name unliked post $title';
      }
      if (action == Log.post.share) {
        return '$name shared post $title';
      }
    }

    if (type == Log.type.comment) {
      Post post = await PostService.instance.get(postId!);
      String title = post.title;
      if (action == Log.comment.create) {
        return '$name commented on post $title';
      }
      if (action == Log.comment.update) {
        return '$name updated comment on post $title';
      }
      if (action == Log.comment.delete) {
        return '$name deleted comment on post $title';
      }
      if (action == Log.comment.like) {
        return '$name liked comment on post $title';
      }
      if (action == Log.comment.unlike) {
        return '$name unliked comment on post $title';
      }
      if (action == Log.comment.share) {
        return '$name shared comment on post $title';
      }
    }

    if (type == Log.type.chat) {
      if (action == Log.chat.open) {
        return '$name opened chat with $otherDisplayName';
      }
    }

    if (type == Log.type.feed) {
      if (action == Log.feed.follow) {
        return '$name followed $otherDisplayName';
      }
      if (action == Log.feed.unfollow) {
        return '$name unfollowed $otherDisplayName';
      }
    }

    return '$name $action $type $otherDisplayName';
  }
}
