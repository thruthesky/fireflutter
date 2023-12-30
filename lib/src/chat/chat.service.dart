import 'package:firebase_database/firebase_database.dart';
import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

/// Chat
///
class ChatService {
  static ChatService? _instance;
  static ChatService get instance => _instance ??= ChatService._();

  ChatService._() {
    dog('--> ChatService._()');
  }

  init() {
    dog('--> ChatService.init()');
  }

  /// Firebase Realtime Database Chat Functions
  ///
  ///

  /// Firebase Realtime Database instance
  FirebaseDatabase get rtdb => FirebaseDatabase.instance;
  DatabaseReference get roomsRef => rtdb.ref().child('chat-rooms');
  DatabaseReference get messageseRef => rtdb.ref().child('chat-messages');
  DatabaseReference roomRef(String roomId) => roomsRef.child(roomId);
  DatabaseReference messageRef({required String roomId}) =>
      rtdb.ref().child('chat-messages').child(roomId);

  /// [roomUserRef] is the reference to the users node under the group chat room. Ex) /chat-rooms/{roomId}/users/{my-uid}
  DatabaseReference roomUserRef(String roomId, String uid) =>
      rtdb.ref().child('chat-rooms/$roomId/users/$uid');

  DatabaseReference get joinsRef => rtdb.ref().child('chat-joins');
  DatabaseReference joinRef(String myUid, String roomId) => joinsRef.child(myUid).child(roomId);

  /// 각 채팅방 마다, 맨 마지막 채팅 메시지의 order 값을 가지고 있는 배열
  /// TODO: 이 변수를 통째로 ChatModel 로 이동하도록 한다.
  ///
  /// 이것은 채팅 메시지를 역순으로 목록하기 위해서 사용하는 것으로, 나중에 입력되는 메시지일 수록 더 적은 음수 값을 저장해야하는데,
  /// 메시지가 저장될 때 그 즉시, -1 로 저장하고,
  /// 나중에, "시간 * -1"을 해서 업데이트를 해준다.
  ///
  final Map<String, int> roomMessageOrder = {};

  /// 채팅방의 메시지 순서(order)를 가져온다.
  /// 만약, [ChatService.instance.roomMessageOrder] 에 값이 없으면 0을 리턴한다.
  int getRoomMessageOrder(String messageRoomId) {
    return ChatService.instance.roomMessageOrder[messageRoomId] ?? 0;
  }

  Future createRoom({
    required String name,
    required bool isGroupChat,
    required bool isOpenGroupChat,
  }) async {
    final room = await ChatRoomModel.create(
      name: name,
      isGroupChat: isGroupChat,
      isOpenGroupChat: isOpenGroupChat,
    );

    return room;
  }

  Future showChatRoom({
    required BuildContext context,
    String? uid,
    String? roomId,
  }) async {
    return showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) => DefaultChatRoomScreen(
        uid: uid,
        roomId: roomId,
      ),
    );
  }
}
