import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';

/// Firebase Realtime Database Chat Functions
///
///

DatabaseReference chatRoomRef({required String uid}) => rtdb.ref().child('chat-rooms/$uid');
DatabaseReference chatMessageRef({required String roomId}) =>
    rtdb.ref().child('chat-messages').child(roomId).child('messages');

/// 각 채팅방 마다 -1을 해서 order 한다.
///
/// 더 확실히 하기 위해서는 order 를 저장 할 때, 이전 order 의 -1 로 하고, 저장이 된 후, createAt 의 -1 을 해 버린다.
final Map<String, int> chatRoomMessageOrder = {};

otherUidFromRoomId(String roomId) {
  return roomId.split('-').firstWhere((uid) => uid != myUid);
}

Future<void> sendChatMessage({
  required String roomId,
  String? text,
  String? url,
}) async {
  chatRoomMessageOrder[roomId] = (chatRoomMessageOrder[roomId] ?? 0) - 1;
  await chatMessageRef(roomId: roomId).push().set({
    'uid': myUid,
    if (text != null) 'text': text,
    if (url != null) 'url': url,
    'order': chatRoomMessageOrder[roomId],
    'createdAt': ServerValue.timestamp,
  });

  updateChatRoom(roomId: roomId, text: text, url: url);
}

Future<void> updateChatRoom({
  required String roomId,
  String? text,
  String? url,
}) async {
  String otherUid = otherUidFromRoomId(roomId);

  // chat room under my room list
  chatRoomRef(uid: myUid!).child(otherUid).set({
    'text': text,
    'url': url,
    'order': chatRoomMessageOrder[roomId],
    'updatedAt': ServerValue.timestamp,
    'newMessage': 0,
  });

// chat room info update under other user room list
  chatRoomRef(uid: otherUid).child(myUid!).set({
    'text': text,
    'url': url,
    'order': chatRoomMessageOrder[roomId],
    'updatedAt': ServerValue.timestamp,
    'newMessage': ServerValue.increment(1),
  });
}

resetChatRoomMessageOrder({required String roomId, required int? order}) async {
  if (chatRoomMessageOrder[roomId] == null) {
    chatRoomMessageOrder[roomId] = 0;
  }

  if (order != null && order < chatRoomMessageOrder[roomId]!) {
    chatRoomMessageOrder[roomId] = order;
  }

  dog('rchat functions resetChatRoomMessageOrder : $roomId, $order, ${chatRoomMessageOrder[roomId]}');
}

/// 일대일 채팅방 ID 를 만든다.
///
/// [myUid] 와 [otherUserUid] 를 정렬해서 합친다.
String singleChatRoomId(String otherUserUid) {
  final uids = [myUid, otherUserUid];
  uids.sort();
  return uids.join('-');
}
