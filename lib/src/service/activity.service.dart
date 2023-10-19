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
    onAppStart();
    UserService.instance.userChanges.listen((user) {
      if (user == null) return;
      onUserSignin();
    });
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
    String? otherDisplayName,
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
      otherDisplayName: otherDisplayName,
    );
  }

  onAppStart() => _log(
        action: 'startApp',
        type: ActivityType.user.name,
      );

  /// user login
  onUserCreate(User user) => _log(
        action: 'create',
        type: ActivityType.user.name,
        uid: user.uid,
        name: user.name,
      );

  onUserUpdate(User user) => _log(
        action: 'update',
        type: ActivityType.user.name,
        uid: user.uid,
        name: user.name,
      );

  /// user login
  onUserSignin() => _log(
        action: 'signin',
        type: ActivityType.user.name,
      );

  onSignout(User user) => _log(
        action: 'signout',
        type: ActivityType.user.name,
        uid: user.uid,
        name: user.name,
      );

  /// user visit other user's profile
  onUserViewedProfile(String otherUid, User? user) => _log(
        action: 'viewProfile',
        type: ActivityType.user.name,
        otherUid: otherUid,
        otherDisplayName: user?.name,
      );

  /// user follow other user
  onUserFollow(String otherUid, bool isFollow) {
    _log(
      action: isFollow == true ? 'follow' : 'unfollow',
      type: ActivityType.user.name,
      otherUid: otherUid,
    );
  }

  /// user like other user
  onUserLike(String otherUid, bool isLike) {
    _log(
      action: isLike == true ? 'like' : 'unlike',
      type: ActivityType.user.name,
      otherUid: otherUid,
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
  onChatRoomOpened(Room? room, User? user) {
    _log(
      action: 'open',
      type: ActivityType.chat.name,
      roomId: room?.roomId,
      title: room?.name,
      otherUid: user?.uid,
      otherDisplayName: user?.name,
    );
  }

  // onChatMessageSent(Room room) {
  //   _log(
  //     action: 'send',
  //     type: ActivityType.chat.name,
  //     roomId: room.roomId,
  //     title: room.name,
  //   );
  // }

  /// user follow other user
  onFeedFollow(String otherUid, bool isFollow) {
    _log(
      action: isFollow == true ? 'follow' : 'unfollow',
      type: ActivityType.feed.name,
      otherUid: otherUid,
    );
  }

  onPostCreate(Post post) {
    _log(
      action: 'create',
      type: ActivityType.post.name,
      postId: post.id,
      title: post.title,
    );
  }

  onPostUpdate(Post post) {
    _log(
      action: 'update',
      type: ActivityType.post.name,
      postId: post.id,
      title: post.title,
    );
  }

  onPostDelete(Post post) {
    _log(
      action: 'delete',
      type: ActivityType.post.name,
      postId: post.id,
      title: post.title,
    );
  }

  onPostLike(Post post, bool isLike) {
    _log(
      action: isLike == true ? 'like' : 'unlike',
      type: ActivityType.post.name,
      postId: post.id,
      title: post.title,
    );
  }

  onCommentCreate(Comment comment) {
    _log(
      action: 'create',
      type: ActivityType.comment.name,
      postId: comment.postId,
      commentId: comment.id,
      title: comment.content,
    );
  }

  onCommentUpdate(Comment comment) {
    _log(
      action: 'update',
      type: ActivityType.comment.name,
      postId: comment.postId,
      commentId: comment.id,
      title: comment.content,
    );
  }

  onCommentDelete(Comment comment) {
    _log(
      action: 'delete',
      type: ActivityType.comment.name,
      postId: comment.postId,
      commentId: comment.id,
      title: comment.content,
    );
  }
}
