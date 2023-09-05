import 'package:fireflutter/fireflutter.dart';

class FeedService with FirebaseHelper {
  /// create singleton

  static FeedService? _instance;
  static FeedService get instance => _instance ??= FeedService._();
  FeedService._();

  bool enable = false;

  init({
    required bool enable,
  }) {
    this.enable = enable;
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
        rtdb.ref('feeds').child(my.uid).child(post.id).set({
          'uid': post.uid,
          'postId': post.id,
          'createdAt': 0 - post.createdAt.millisecondsSinceEpoch,
        });
      }
    } else {
      // remove all posts from rtdb
      rtdb.ref('feeds').child(my.uid).orderByChild('uid').equalTo(otherUid).once().then((value) {
        for (final node in value.snapshot.children) {
          node.ref.remove();
        }
      });
    }
    return re;
  }

  /// Adding posts into the feeds of the followers.
  Future create({required Post post}) async {
    if (enable == false) return;
    List<Future> feedUpdates = [];
    for (String followerUid in my.followers) {
      feedUpdates.add(rtdb.ref('feeds').child(followerUid).child(post.id).set({
        'uid': post.uid,
        'postId': post.id,
        'createdAt': 0 - post.createdAt.millisecondsSinceEpoch,
      }));
    }
    await Future.wait(feedUpdates);
  }

  /// Used for updating RTDB feeds to followers' feed
  Future delete({required Post post}) async {
    List<Future> feedDeletes = [];
    for (String followerUid in my.followers) {
      feedDeletes.add(rtdb.ref('feeds').child(followerUid).child(post.id).remove());
    }
    return await Future.wait(feedDeletes);
  }
}
