import 'package:fireflutter/fireflutter.dart';

class ActivityService {
  static ActivityService? _instance;
  static ActivityService get instance {
    _instance ??= ActivityService();
    return _instance!;
  }

  bool enableActivityLog = false;

  ActivityService() {
    // dog('ActivityService::constructor');
  }

  init({
    enableActivityLog = false,
  }) {
    this.enableActivityLog = enableActivityLog;
  }

  /// only use this for logging activity
  ///
  _log({
    required String action,
    required String type,
    String? uid,
    String? name,
    String? postId,
    String? commentId,
    String? roomId,
    String? title,
    String? otherUid,
  }) {
    if (enableActivityLog == false) return;

    dog('ActivityService::log:: ${action.toString()}');
    Activity.create(
      action: action,
      type: type,
      uid: uid,
      name: name,
      postId: postId,
      commentId: commentId,
      roomId: roomId,
      title: title,
      otherUid: otherUid,
      otherDisplayName: otherUid,
    );
  }

  /// user login
  onUserCreate(User user) => _log(
        action: 'create',
        type: 'user',
        uid: user.uid,
        name: user.name,
      );

  onUserUpdate(User user) => _log(
        action: 'update',
        type: 'user',
        uid: user.uid,
        name: user.name,
      );

  onSignout(User user) => _log(
        action: 'signout',
        type: 'user',
        uid: user.uid,
        name: user.name,
      );

  /// user visit other user's profile
  onUserViewedProfile(String otherUid) => _log(
        action: 'viewProfile',
        type: 'user',
        otherUid: otherUid,
      );

  /// user follow other user
  onUserFollow(String otherUid, bool isFollow) {
    _log(
      action: isFollow == true ? 'follow' : 'unfollow',
      type: 'user',
      otherUid: otherUid,
    );
  }

  /// user like other user
  onUserLike(String otherUid, bool isLike) {
    _log(
      action: isLike == true ? 'like' : 'unlike',
      type: 'user',
      otherUid: otherUid,
    );
  }

  /// type can be any of the following:
  /// 'post', 'comment', 'user', 'chat'
  onFavorite({required String id, required bool isFavorite, required String type}) {
    _log(
      action: isFavorite == true ? 'favorite' : 'unfavorite',
      type: type,
      postId: type == ActivityType.post.name ? id : null,
      commentId: type == ActivityType.comment.name ? id : null,
      roomId: type == ActivityType.chat.name ? id : null,
      otherUid: type == ActivityType.user.name ? id : null,
    );
  }

  /// type can be any of the following:
  /// 'post', 'comment', 'user', 'chat', 'feed'
  onShare({required String id, required String type}) => _log(
        action: 'share',
        type: type,
        postId: type == ActivityType.post.name ? id : null,
        commentId: type == ActivityType.comment.name ? id : null,
        roomId: type == ActivityType.chat.name ? id : null,
        otherUid: type == ActivityType.user.name ? id : null,
      );

  /// user open a room or 1:1 chat
  onChatRoomOpened(Room room) {
    _log(
      action: 'openChatRoom',
      type: 'chat',
      roomId: room.roomId,
      title: room.name,
    );
  }
}
