import 'package:firebase_database/firebase_database.dart';
import 'package:fireship/fireship.dart';

class Ref {
  Ref._();

  static DatabaseReference root = FirebaseDatabase.instance.ref();

  /// User
  static DatabaseReference users = root.child('users');
  static DatabaseReference userProfilePhotos = root.child('profile-photos');

  /// Chat Message
  static DatabaseReference chatMessages = root.child('chat-messages');

  static DatabaseReference get joinsRef => root.child(Path.joins);
  static DatabaseReference join(String myUid, String roomId) =>
      root.child(Path.join(myUid, roomId));
  @Deprecated('Use join() instead')
  static DatabaseReference joinRef(String myUid, String roomId) =>
      joinsRef.child(myUid).child(roomId);

  /// Forum
  static DatabaseReference posts = root.child(Folder.posts);

  /// # Category (Post)
  static DatabaseReference category(String category) => posts.child(category);
  static DatabaseReference post(String category, String id) => Ref.category(category).child(id);
  static DatabaseReference postsSummary = root.child('posts-summary');
  static DatabaseReference postSummary(String category, String id) =>
      root.child('posts-summary').child(category).child(id);

  /// Forum Comments
  static DatabaseReference comments(String category, String postId) =>
      post(category, postId).child('comments');
  static DatabaseReference comment(String category, String postId, String id) =>
      comments(category, postId).child(id);

  /// Report
  static DatabaseReference reports = root.child(Folder.reports);

  /// Token, FCM, Notification
  static DatabaseReference userFcmTokens = root.child(Folder.userFcmTokens);
  static Query userTokens(String uid) => userFcmTokens.orderByChild('uid').equalTo(uid);
}
