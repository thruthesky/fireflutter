import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';

class ChatJoin {
  /// Paths and Refs
  static const String nodeName = 'chat-joins';
  static DatabaseReference root = FirebaseDatabase.instance.ref();
  static DatabaseReference ref = root.child(nodeName);

  /// Chat Join 은 /chat-joins/{myUid}/{roomId} 에 저장된다. 항상 나의 uid 가 앞에 온다.
  static String join(String myUid, String roomId) => '$nodeName/$myUid/$roomId';

  static DatabaseReference joinRef(String myUid, String roomId) =>
      root.child(join(myUid, roomId));

  static DatabaseReference photoRef(String roomId) =>
      root.child('$nodeName/$myUid/$roomId/${Field.photoUrl}');
}
