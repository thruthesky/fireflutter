import 'package:fireflutter/fireflutter.dart';

class FeedService with FirebaseHelper {
  /// create singleton

  static FeedService? _instance;
  static FeedService get instance => _instance ??= FeedService._();

  FeedService._();

  Future follow(String uid) async {
    await User.fromUid(uid).followed(my.uid);
    await my.follow(uid);

    // get last 20 posts and save it under rtdb
    final posts = await PostService.instance.gets(uid: uid, limit: 20);

    for (var post in posts) {
      rtdb.ref('feeds').child(my.uid).child(post.id).set({
        'uid': post.uid,
        'postId': post.id,
        'createdAt': 0 - post.createdAt.millisecondsSinceEpoch,
      });
    }
  }
}
