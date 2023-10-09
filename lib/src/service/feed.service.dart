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

  Map<String, dynamic> convertIntoFeedData(Post post) {
    post.data?.remove('createdAt');
    return {
      'uid': post.uid,
      'postId': post.id,
      'createdAt': 0 - post.createdAt.millisecondsSinceEpoch,
      'title': post.title,
      'content': post.content,
      'categoryId': post.categoryId,
      'youtubeId': post.youtubeId,
      'urls': post.urls,
      'hashtags': post.hashtags,
      'noOfComments': post.noOfComments,
    };
  }

  /// When a user follows another user, we will send push notification to that user
  Future sendNotificationOnFollow(String otherUid, isFollowed) async {
    if (enableNotificationOnFollow == false) return;
    if (isFollowed == false) return;

    MessagingService.instance.queue(
      title: "${my.name} is following you.",
      body: 'You have new follower',
      id: myUid,
      uids: [otherUid],
      type: NotificationType.user.name,
    );
  }

  /// follow or unfollow
  ///
  ///
  Future<bool> follow(String otherUid) async {
    final re = await my.follow(otherUid);

    if (re) {
      // get last 20 posts and save it under rtdb
      final posts = await PostService.instance.gets(uid: otherUid, limit: 20);
      for (final post in posts) {
        rtdb.ref('feeds').child(my.uid).child(post.id).set(convertIntoFeedData(post));
      }
    } else {
      // remove all posts from rtdb
      rtdb.ref('feeds').child(my.uid).orderByChild('uid').equalTo(otherUid).once().then((value) {
        for (final node in value.snapshot.children) {
          node.ref.remove();
        }
      });
    }

    /// callback function when this user follows another user.
    sendNotificationOnFollow(otherUid, re);
    onFollow?.call(otherUid, re);

    return re;
  }

  /// Remove my uid from the followers field of the other user document in /users document collection.
  Future<void> removeFromFollowers(String otherUid) async {
    dog('begin - removeFromFollowers: $otherUid');
    await userDoc(otherUid).update({
      'followers': FieldValue.arrayRemove([myUid]),
    });
    dog('end - removeFromFollowers: $otherUid');
  }

  /// Adding posts into the feeds of the followers.
  Future create({required Post post}) async {
    if (enable == false) return;
    List<Future> feedUpdates = [];
    // My feed should be also viewable by me.
    for (String followerUid in [...my.followers, myUid!]) {
      feedUpdates.add(rtdb.ref('feeds').child(followerUid).child(post.id).set(convertIntoFeedData(post)));
    }
    await Future.wait(feedUpdates);
  }

  /// Updates the feeds
  Future update({required Post post}) async {
    if (enable == false) return;
    List<Future> feedUpdates = [];
    // My feed should be also viewable by me.
    for (String followerUid in [...my.followers, myUid!]) {
      feedUpdates.add(rtdb.ref('feeds').child(followerUid).child(post.id).update({
        'title': post.title,
        'content': post.content,
        'urls': post.urls,
        'youtubeId': post.youtubeId,
        'hashtags': post.hashtags,
        'noOfComments': post.noOfComments,
      }));
    }
    await Future.wait(feedUpdates);
  }

  /// Used for updating RTDB feeds to followers' feed
  Future delete({required Post post, List<String>? fromUids}) async {
    List<Future> feedDeletes = [];
    for (String followerUid in fromUids ?? my.followers) {
      feedDeletes.add(rtdb.ref('feeds').child(followerUid).child(post.id).remove());
    }
    return await Future.wait(feedDeletes);
  }
}
