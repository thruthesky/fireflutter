import 'package:firebase_database/firebase_database.dart';

class Ref {
  Ref._();

  static DatabaseReference root = FirebaseDatabase.instance.ref();

  /// User
  static DatabaseReference users = root.child('users');
  static DatabaseReference userProfilePhotos = root.child('profile-photos');

  /// Chat
  static DatabaseReference chatMessages = root.child('chat-messages');

  static DatabaseReference get joinsRef => root.child(Path.joins);
  static DatabaseReference join(String myUid, String roomId) =>
      root.child(Path.join(myUid, roomId));
  @Deprecated('Use join() instead')
  static DatabaseReference joinRef(String myUid, String roomId) =>
      joinsRef.child(myUid).child(roomId);
}

class Path {
  Path._();

  /// User
  static const String users = 'users';
  static const String userProfilePhotos = 'profile-photos';

  /// Chat
  static const String chatMessages = 'chat-messages';

  static const String joins = 'chat-joins';
  static String join(String myUid, String roomId) => '$joins/$myUid/$roomId';
}
