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

  /// Chat Room
  static DatabaseReference chatRoom = root.child('chat-rooms');
  static Query listOfUsers(String uid, String roomId) =>
      chatRoom.orderByChild('users').equalTo(uid);

  static DatabaseReference get joinsRef => root.child(Path.joins);
  static DatabaseReference join(String myUid, String roomId) =>
      root.child(Path.join(myUid, roomId));
  @Deprecated('Use join() instead')
  static DatabaseReference joinRef(String myUid, String roomId) =>
      joinsRef.child(myUid).child(roomId);

  /// Report
  static DatabaseReference reports = root.child(Folder.reports);

  /// Token, FCM, Notification
  static DatabaseReference userFcmTokens = root.child(Folder.userFcmTokens);
  static Query userTokens(String uid) => userFcmTokens.orderByChild('uid').equalTo(uid);
}
