import 'package:fireflutter/fireflutter.dart';

class FeedService with FirebaseHelper {
  /// create singleton

  static FeedService? _instance;
  static FeedService get instance => _instance ??= FeedService._();

  FeedService._();

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

  Future<List<Post>> getAllByMinusDate() async {
    final feeds = await rtdb.ref('feeds').child(my.uid).orderByChild('createdAt').once();
    List<Future<Post>> posts = [];
    for (final feed in feeds.snapshot.children) {
      posts.add(Post.get((feed.value as Map)['postId']));
    }
    return await Future.wait(posts);
  }
}
