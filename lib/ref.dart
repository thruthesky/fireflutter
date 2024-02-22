import 'package:firebase_database/firebase_database.dart';
import 'package:fireship/fireship.dart';

class Ref {
  Ref._();

  static DatabaseReference root = FirebaseDatabase.instance.ref();

  /// Admins
  static DatabaseReference admins = root.child('admins');

  /// Bookmark
  static DatabaseReference bookmarks = root.child(Folder.bookmarks);

  /// User
  static DatabaseReference users = root.child('users');
  static DatabaseReference userProfilePhotos = root.child('profile-photos');
  static DatabaseReference userWhoILike = root.child(Path.userWhoILike);
  static DatabaseReference userWhoLikeMe = root.child(Path.userWhoLikeMe);

  /// Chat Messages Folder(Node) for all room
  static DatabaseReference chatMessages = root.child('chat-messages');

  /// Chat messages for the room.
  static DatabaseReference chatRoomMessages(roomId) =>
      chatMessages.child(roomId);

  static DatabaseReference get joinsRef => root.child(Path.joins);
  static DatabaseReference join(String myUid, String roomId) =>
      root.child(Path.join(myUid, roomId));

  /// Forum
  static DatabaseReference posts = root.child(Folder.posts);

  static DatabaseReference postSummaries = root.child('post-summaries');
  static DatabaseReference postSummary(String category, String id) =>
      postSummaries.child(category).child(id);
  static DatabaseReference postAllSummaries =
      root.child(Folder.postAllSummaries);

  /// # Category (Post)
  static DatabaseReference category(String category) => posts.child(category);
  static DatabaseReference post(String category, String id) =>
      Ref.category(category).child(id);

  /// Forum Comments
  static DatabaseReference comments = root.child(Folder.comments);
  static DatabaseReference postComments(String postId) =>
      root.child(Path.comments(postId));
  static DatabaseReference comment(String postId, String commentId) =>
      root.child(Folder.comments).child(postId).child(commentId);

  /// Report
  static DatabaseReference reports = root.child(Folder.reports);

  /// Token, FCM, Notification
  static DatabaseReference userFcmTokens = root.child(Folder.userFcmTokens);
  static Query userTokens(String uid) =>
      userFcmTokens.orderByChild('uid').equalTo(uid);
}
