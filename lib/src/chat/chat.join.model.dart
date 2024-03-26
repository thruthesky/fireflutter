import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';

class ChatJoin {
  /// Paths and Refs
  static const String nodeName = 'chat-joins';
  static DatabaseReference rootRef = FirebaseDatabase.instance.ref();
  static DatabaseReference ref = rootRef.child(nodeName);

  /// Chat Join 은 /chat-joins/{myUid}/{roomId} 에 저장된다. 항상 나의 uid 가 앞에 온다.
  static String join(String myUid, String roomId) => '$nodeName/$myUid/$roomId';

  /// /chat-joins/{나의 uid}/{roomId} 의 reference 를 리턴한다.
  static DatabaseReference joinRef(String myUid, String roomId) =>
      rootRef.child(join(myUid, roomId));

  static DatabaseReference nameRef(String roomId) =>
      rootRef.child('$nodeName/$myUid/$roomId/${Field.name}');
  static DatabaseReference photoRef(String roomId) =>
      rootRef.child('$nodeName/$myUid/$roomId/${Field.photoUrl}');
}
