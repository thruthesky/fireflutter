import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'activity.g.dart';

@JsonSerializable()
class Activity {
  final String action;
  final String type;
  final String uid;
  final String name;
  final String? postId;
  final String? commentId;
  final String? roomId;
  final String? title;
  final String? otherUid;
  final String? otherDisplayName;

  @FirebaseDateTimeConverter()
  final DateTime createdAt;

  Activity({
    required this.action,
    required this.type,
    required this.uid,
    required this.name,
    required this.createdAt,
    this.postId,
    this.commentId,
    this.roomId,
    this.title,
    this.otherUid,
    this.otherDisplayName,
  });

  /// dont use directly,
  /// use [ActivityService.instance.log(...)] instead
  static Future<void> create({
    required String action,
    required String type,
    String? uid,
    String? name,
    String? postId,
    String? commentId,
    String? roomId,
    String? title,
    String? otherUid,
    String? otherDisplayName,
  }) async {
    final Map<String, dynamic> data = {
      'action': action,
      'type': type, // 'post', 'comment', 'user', 'chat'
      'uid': uid ?? myUid,
      'name': name ?? my!.name,
      if (postId != null) 'postId': postId,
      if (commentId != null) 'commentId': commentId,
      if (roomId != null) 'roomId': roomId,
      if (title != null) 'title': title,
      if (otherUid != null) 'otherUid': otherUid,
      if (otherDisplayName != null) 'otherDisplayName': otherDisplayName,
      'createdAt': ServerValue.timestamp,
    };
    final re = activityLogRef.push();
    await re.set(data);
    final act = await activityLogRef.child(re.key!).get();
    re.update({'reverseCreatedAt': (act.value as dynamic)['createdAt'] * -1});
    activityUserLogRef().push().set({...data, 'reverseCreatedAt': (act.value as dynamic)['createdAt'] * -1});
  }

  factory Activity.fromJson(Map<String, dynamic> json) {
    return _$ActivityFromJson(json);
  }

  factory Activity.fromDocumentSnapshot(DataSnapshot snapshot) {
    return Activity.fromJson(
      {
        ...(snapshot.value as Map<dynamic, dynamic>),
        ...{'id': snapshot.key},
      },
    );
  }
  Map<String, dynamic> toJson() => _$ActivityToJson(this);

  @override
  String toString() => 'Activity:: (${toJson()})';

  Future<String> get getName async {
    String name = this.name;
    if (name.isEmpty) {
      final user = await User.get(uid) as User;
      name = user.getDisplayName;
    }
    return name;
  }

  Future<String> get getOtherName async {
    String otherDisplayName = this.otherDisplayName ?? '';
    if (otherDisplayName.isEmpty && otherUid != null) {
      final user = await User.get(otherUid!) as User;
      otherDisplayName = user.getDisplayName;
    }
    return otherDisplayName;
  }

  Future<String> get getMessage async {
    String name = await getName;
    String otherDisplayName = await getOtherName;

    if (type == ActivityType.user.name) {
      return userActivityMessage(name, otherDisplayName);
    }

    if (type == ActivityType.post.name) {
      return postActivityMessage(name, otherDisplayName);
    }

    if (type == ActivityType.comment.name) {
      return commentActivityMessage(name, otherDisplayName);
    }

    if (type == ActivityType.chat.name) {
      return chatActivityMessage(name, otherDisplayName);
    }

    if (type == ActivityType.feed.name) {
      return feedActivityMessage(name, otherDisplayName);
    }

    return '$name $action $type $otherDisplayName';
  }

  String userActivityMessage(name, otherDisplayName) {
    if (action == ActivityUserAction.create.name) {
      return '$name created an account';
    }
    if (action == ActivityUserAction.update.name) {
      return '$name updated profile';
    }
    if (action == ActivityUserAction.delete.name) {
      return '$name deleted account';
    }
    if (action == ActivityUserAction.signin.name) {
      return '$name signed in';
    }
    if (action == ActivityUserAction.signout.name) {
      return '$name signed out';
    }
    if (action == ActivityUserAction.like.name) {
      return '$name liked user $otherDisplayName';
    }
    if (action == ActivityUserAction.unlike.name) {
      return '$name unliked user $otherDisplayName';
    }
    if (action == ActivityUserAction.follow.name) {
      return '$name followed user $otherDisplayName';
    }
    if (action == ActivityUserAction.unfollow.name) {
      return '$name unfollowed user $otherDisplayName';
    }
    if (action == ActivityUserAction.viewProfile.name) {
      return '$name viewed profile of $otherDisplayName';
    }
    if (action == ActivityUserAction.favorite.name) {
      return '$name favorited user $otherDisplayName';
    }
    return '$name $action $type $otherDisplayName';
  }

  String postActivityMessage(name, otherDisplayName) {
    if (action == ActivityPostAction.create.name) {
      return '$name created a post ${title ?? postId}';
    }
    if (action == ActivityPostAction.update.name) {
      return '$name updated a post ${title ?? postId}';
    }
    if (action == ActivityPostAction.delete.name) {
      return '$name deleted a post ${title ?? postId}';
    }
    if (action == ActivityPostAction.like.name) {
      return '$name liked post ${title ?? postId}';
    }
    if (action == ActivityPostAction.unlike.name) {
      return '$name unliked post ${title ?? postId}';
    }
    if (action == ActivityPostAction.favorite.name) {
      return '$name favorited post ${title ?? postId}';
    }
    if (action == ActivityPostAction.unfavorite.name) {
      return '$name unfavorited post ${title ?? postId}';
    }
    if (action == ActivityPostAction.share.name) {
      return '$name shared post ${title ?? postId}';
    }
    return '$name $action $type ${title ?? postId}';
  }

  String commentActivityMessage(name, otherDisplayname) {
    if (action == ActivityCommentAction.create.name) {
      return '$name commented on post ${title ?? postId}';
    }
    if (action == ActivityCommentAction.update.name) {
      return '$name updated comment on post ${title ?? postId}';
    }
    if (action == ActivityCommentAction.delete.name) {
      return '$name deleted comment on post ${title ?? postId}';
    }
    if (action == ActivityCommentAction.like.name) {
      return '$name liked comment on post ${title ?? postId}';
    }
    if (action == ActivityCommentAction.unlike.name) {
      return '$name unliked comment on post ${title ?? postId}';
    }
    if (action == ActivityCommentAction.favorite.name) {
      return '$name favorited comment on post ${title ?? postId}';
    }
    if (action == ActivityCommentAction.unfavorite.name) {
      return '$name unfavorited comment on post ${title ?? postId}';
    }
    if (action == ActivityCommentAction.share.name) {
      return '$name shared comment on post ${title ?? postId}';
    }
    return '$name $action $type ${title ?? postId}';
  }

  String chatActivityMessage(name, otherDisplayName) {
    if (action == ActivityChatAction.open.name) {
      return '$name opened chat with $otherDisplayName';
    }
    if (action == ActivityChatAction.send.name) {
      return '$name sent message to $otherDisplayName';
    }
    if (action == ActivityChatAction.share.name) {
      return '$name shared chat with $otherDisplayName';
    }
    if (action == ActivityChatAction.favorite.name) {
      return '$name favorited chat with $otherDisplayName';
    }
    if (action == ActivityChatAction.unfavorite.name) {
      return '$name unfavorited chat with $otherDisplayName';
    }
    return '$name $action $type $otherDisplayName';
  }

  String feedActivityMessage(name, otherDisplayName) {
    if (action == ActivityFeedAction.follow.name) {
      return '$name followed $otherDisplayName';
    }
    if (action == ActivityFeedAction.unfollow.name) {
      return '$name unfollowed $otherDisplayName';
    }
    if (action == ActivityFeedAction.share.name) {
      return '$name shared $otherDisplayName';
    }
    return '$name $action $type $otherDisplayName';
  }
}
