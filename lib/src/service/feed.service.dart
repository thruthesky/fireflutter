import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';

class FeedService {
  /// create singleton

  static FeedService? _instance;
  static FeedService get instance => _instance ??= FeedService._();
  FeedService._();

  bool enable = false;

  bool enableNotificationOnFollow = false;

  void Function(String otherUid, bool isFollowed)? onFollow;

  init({
    required bool enable,
    bool enableNotificationOnFollow = false,
    void Function(String otherUid, bool isFollowed)? onFollow,
  }) {
    this.enable = enable;
    this.enableNotificationOnFollow = enableNotificationOnFollow;
    this.onFollow = onFollow;
  }

  /// When a user follows another user, we will send push notification to that user
  Future sendNotificationOnFollow(String otherUid, isFollowed) async {
    if (enableNotificationOnFollow == false) return;
    if (isFollowed == false) return;

    MessagingService.instance.queue(
      title: "${my!.name} is following you.",
      body: 'You have new follower',
      id: myUid,
      uids: [otherUid],
      type: NotificationType.user.name,
    );
  }

  /// Follow or unfollow
  ///
  /// Returns true if followed, false if unfollowed.
  Future<bool> follow(String otherUid) async {
    if (enable == false) return false;

    /// Don't use [my] on unit testing due to the latency of the sync with
    /// firestore, it would have a wrong value.
    final User me = await UserService.instance.get(myUid!, reload: true) as User;
    final re = await me.follow(otherUid);

    if (re) {
      // get last 50 and put my uid into followers
      final posts = await PostService.instance.gets(uid: otherUid, limit: 50);
      for (final post in posts) {
        post.updateFollowers(FieldValue.arrayUnion([myUid]));
      }
    } else {
      // Get all and remove my uid from followers
      //
      // Attention: This is not scalable. It may work slow and download a lot of data over network.
      //
      // To solve this problem, If you are worried about reading all posts, you should limit it to
      // the posts of last 6 months. And when you show the feeed, you should
      // also limit it to 6 months.
      final posts = await PostService.instance.gets(uid: otherUid, limit: 0);
      for (final post in posts) {
        post.updateFollowers(FieldValue.arrayRemove([myUid]));
      }
    }

    /// callback function when this user follows another user.
    sendNotificationOnFollow(otherUid, re);
    onFollow?.call(otherUid, re);

    /// TODO @lancelynyrd - activity log
    // ActivityService.instance.onFeedFollow(otherUid, re);

    return re;
  }
}
