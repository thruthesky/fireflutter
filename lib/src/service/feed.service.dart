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
      rtdb.ref('feeds').child(my.uid).child('uid').equalTo(otherUid).once().then((value) {
        for (final post in value.snapshot.children) {
          print(post.value);
        }
      });

      /// .remove();
    }

    return re;
  }
}
