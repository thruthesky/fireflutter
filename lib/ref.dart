import 'package:firebase_database/firebase_database.dart';
import 'package:fireship/fireship.dart';

class Ref {
  Ref._();

  static DatabaseReference root = FirebaseDatabase.instance.ref();

  /// Action
  static DatabaseReference action = root.child(Folder.action);
  static DatabaseReference get chatJoinAction =>
      root.child(Path.chatJoinAction);
  static DatabaseReference get userViewAction =>
      root.child(Path.userViewAction);
  static DatabaseReference get postCreateAction =>
      root.child(Path.postCreateAction);
  static DatabaseReference get commentCreateAction =>
      root.child(Path.commentCreateAction);

  /// Activity
  static DatabaseReference activity = root.child(Folder.activity);
  static DatabaseReference get userLikeActivity =>
      root.child(Path.userLikeActivity);
  static DatabaseReference get userViewActivity =>
      root.child(Path.userViewActivity);
  static DatabaseReference get postCreateActivity =>
      root.child(Path.postCreateActivity);
  static DatabaseReference get commentCreateActivity =>
      root.child(Path.commentCreateActivity);
  static DatabaseReference get chatJoinActivity =>
      root.child(Path.chatJoinActivity);

  /// Admins
  static DatabaseReference admins = root.child('admins');

  /// Bookmark
  static DatabaseReference bookmarks = root.child(Folder.bookmarks);

  /// User
  static DatabaseReference users = root.child('users');
  static DatabaseReference user(String uid) => users.child(uid);
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
