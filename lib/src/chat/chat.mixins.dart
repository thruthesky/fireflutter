import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';

mixin ChatMixins {
  /// My room list collection. There are all chat user list in the collection.
  ///
  ///
  /// ```dart
  /// chat.roomsCol.orderBy('timestamp', descending: true);
  /// ```
  static CollectionReference get myRoomsCol =>
      FirebaseFirestore.instance.collection('chat/rooms/$myUid');

  /// Login user's firebase uid.
  static String get myUid => User.instance.uid!;

  /// Chat room ID
  ///
  /// - Return chat room id of login user and the other user.
  /// - The location of chat room is at `/rooms/[ID]`.
  /// - Chat room ID is composited with login user UID and other user UID by alphabetic order.
  ///   - If user.uid = 3 and otherUserLoginId = 4, then the result is "3-4".
  ///   - If user.uid = 321 and otherUserLoginId = 1234, then the result is "1234-321"
  static String getRoomId(String otherUid) {
    return getChatRoomDocumentId(myUid, otherUid);
  }

  /// messages collection of chat user.
  static CollectionReference messagesCol(String otherUid) =>
      FirebaseFirestore.instance.collection('chat').doc('messages').collection(getRoomId(otherUid));

  /// Chat room info.
  ///
  ///
  /// - `/chat/rooms/[my-uid]/[other-uid]`
  // DocumentReference myOtherRoomInfoDoc(String otherUid) => myRoomsCol.doc(otherUid);

  /// Chat room info
  ///
  /// /chat/rooms/[other-uid]/[my-uid]
  // @Deprecated('Do not use - it is confusing')
  // DocumentReference otherMyRoomInfoDoc(String otherUid) => otherRoomsCol(otherUid).doc(myUid);

  static CollectionReference otherRoomsCol(String otherUid) =>
      FirebaseFirestore.instance.collection('chat/rooms/$otherUid');

  /// Chat room ID
  ///
  /// - Return chat room id of login user and the other user.
  /// - The location of chat room is at `/rooms/[ID]`.
  /// - Chat room ID is composited with login user UID and other user UID by alphabetic order.
  ///   - If myLoginId = 3 and otherUserLoginId = 4, then the result is "3-4".
  ///   - If myLoginId = 321 and otherUserLoginId = 1234, then the result is "1234-321"
  static String getChatRoomDocumentId(String myLoginId, String otherUserLoginId) {
    return myLoginId.compareTo(otherUserLoginId) < 0
        ? "${myLoginId}__$otherUserLoginId"
        : "${otherUserLoginId}__$myLoginId";
  }

  static CollectionReference get myRoomsBlockedCol =>
      FirebaseFirestore.instance.collection('chat/blocks/$myUid');
}
