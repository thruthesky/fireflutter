import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// Chat
///
class ChatService {
  static ChatService? _instance;
  static ChatService get instance => _instance ??= ChatService._();

  ChatService._() {
    // dog('--> ChatService._()');
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
  DatabaseReference joinRef(String myUid, String roomId) =>
      joinsRef.child(myUid).child(roomId);

  ChatCustomize customize = const ChatCustomize();

  Function(ChatModel)? testBeforeSendMessage;

  Function(ChatMessage)? afterMessageSent;

  /// Warning! this is a dangerous function. Don't use the reference to the database directly because the data is not exists yet in the database.
  ///
  /// Don't do anything with the database in this call back function. This is only for the client side and for chaing the message from the memory only.
  Future<ChatMessage> Function(ChatMessage)? beforeMessageSent;

  /// init
  init({
    ChatCustomize? customize,
    Function(ChatModel)? testBeforeSendMessage,
    Function(ChatMessage)? afterMessageSent,
    Future<ChatMessage> Function(ChatMessage)? beforeMessageSent,
  }) {
    // dog('--> ChatService.init()');
    this.customize = customize ?? this.customize;
    this.testBeforeSendMessage = testBeforeSendMessage;
    this.afterMessageSent = afterMessageSent;
    this.beforeMessageSent = beforeMessageSent;
  }

  Future createRoom({
    required String name,
    required bool isGroupChat,
    required bool isOpenGroupChat,
  }) async {
    final room = await ChatRoom.create(
      name: name,
      isOpenGroupChat: isOpenGroupChat,
    );

    return room;
  }

  /// 채팅방 입장
  ///
  /// 채팅방을 보여준다. 채팅방을 입장 할 때에는 [uid], [roomId] 또는 [room] 중 하나를
  /// 전달하면 된다.
  ///
  /// [uid] 는 1:1 채팅방에서 다른 사용자의 uid 이다.
  ///
  /// [roomId] 는 채팅방의 id 이다.
  ///
  /// [room] 는 채팅방의 정보이다. [room] 을 전달하면 보다 빠르게 화면을 보여 줄 수 있다.
  Future showChatRoomScreen({
    required BuildContext context,
    String? uid,
    String? roomId,
    ChatRoom? room,
  }) async {
    /// 채팅방 입장을 할 때, DB 업데이트를 하므로, 메시지를 보낼 때에는 해제 계산이 되어져 있다.
    ///

    /// Check if it hits limit except the user is admin
    if (isAdmin == false) {
      if (await ActionLogService.instance.chatJoin.isOverLimit(
        roomId: room?.id ?? roomId ?? singleChatRoomId(uid!),
      )) return;
    }

    if (context.mounted) {
      return showGeneralDialog(
        context: context,
        pageBuilder: (context, animation, secondaryAnimation) =>
            DefaultChatRoomScreen(
          uid: uid,
          roomId: roomId,
          room: room,
        ),
      );
    }
  }

  @Deprecated('Use showChatRoomScreen instead')
  Future showChatRoom({
    required BuildContext context,
    String? uid,
    String? roomId,
    ChatRoom? room,
  }) async {
    return await showChatRoomScreen(
      context: context,
      uid: uid,
      roomId: roomId,
      room: room,
    );
  }

  Future<ChatRoom?> showChatRoomCreate({required BuildContext context}) async {
    return await showDialog<ChatRoom?>(
      context: context,
      builder: (_) => const DefaultChatRoomEditDialog(),
    );
  }

  Future showChatRoomSettings({
    required BuildContext context,
    required String roomId,
  }) async {
    return await showDialog<ChatRoom?>(
      context: context,
      builder: (_) => DefaultChatRoomEditDialog(roomId: roomId),
    );
  }

  /// Display a dialog to invite a user to a chat room.
  Future showInviteScreen({
    required BuildContext context,
    required ChatRoom room,
  }) async {
    return await showGeneralDialog<ChatRoom?>(
      context: context,
      pageBuilder: (_, __, ___) => DefaultChatRoomInviteScreen(room: room),
    );
  }

  Future showMembersScreen({
    required BuildContext context,
    required ChatRoom room,
  }) async {
    return await showGeneralDialog(
      context: context,
      pageBuilder: (_, __, ___) => DefaultChatRoomMembersScreen(
        room: room,
      ),
    );
  }
}
