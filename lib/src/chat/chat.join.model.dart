import 'package:firebase_database/firebase_database.dart';

class ChatJoinModel {
  /// Paths and Refs
  static const String nodeName = 'chat-joins';
  static DatabaseReference root = FirebaseDatabase.instance.ref();
  static DatabaseReference ref = root.child(nodeName);

  static String join(String myUid, String roomId) => '$nodeName/$myUid/$roomId';

  static DatabaseReference joinRef(String myUid, String roomId) =>
      root.child(join(myUid, roomId));
}
