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
  DatabaseReference roomRef(String roomId) => roomsRef.child(roomId);

  DatabaseReference settingRef(String roomId) =>
      rtdb.ref().child('settings/chat-rooms/$roomId');

  /// 전체 채팅방 ref
  DatabaseReference get messagesRef => rtdb.ref().child('chat-messages');

  /// 채팅방 1개 ref
  DatabaseReference messageRef({required String roomId}) =>
      rtdb.ref().child('chat-messages').child(roomId);

  /// [roomUserRef] is the reference to the users node under the group chat room. Ex) /chat-rooms/{roomId}/users/{my-uid}
  DatabaseReference roomUserRef(String roomId, String uid) =>
      rtdb.ref().child('chat-rooms/$roomId/users/$uid');

  /// 로그인한 사용자의 채팅방 목록 reference 이다.
  ///
  /// 로그인한 사용자의 채팅방 목록을 가져와 화면에 보여주거나, 새로운 채팅 메시지 수를 화면에 표시하고자 할 때 등에 사용하면 된다.
  DatabaseReference get joinsRef => rtdb.ref().child('chat-joins');
  DatabaseReference joinRef(String myUid, String roomId) =>
      joinsRef.child(myUid).child(roomId);

  ChatCustomize customize = const ChatCustomize();

  /// Do something before the message is sent.
  ///
  /// You can translate the text into other language or do something else.
  ///
  /// [message] is the message that is going to be sent. It has text, url, etc. You can modify it and return it.
  ///
  /// [chatModel] is the chat model that contains the room id, my uid, etc. You can now who you are chatting with with this.
  Future<Map<String, dynamic>> Function(
      Map<String, dynamic> message, ChatModel chatModel)? beforeMessageSent;
  Function(ChatMessage)? afterMessageSent;

  /// gives chatroomsetting option
  /// by default enableVerifiedUserOption and enableGenderOption is set to true
  ChatRoomSettings chatRoomSettings = const ChatRoomSettings();

  /// Before the Single Chat Room create
  ///
  /// You can intercept/do something before the user create the single chat room.
  ///
  /// [otherUid] is the other user uid the user is trying to chat with.
  Future<void> Function(String otherUid)? beforeSingleChatRoomCreate;

  /// Before the  user join the Group Chat Room
  ///
  /// You can intercept/do something before the user join the group chat room.
  Future<void> Function(ChatRoom room)? beforeGroupChatRoomJoin;

  /// init
  /// [chatRoomSettings] give chat room settings to enable verification and gender option
  /// [customize] give customize option to customize chat room screen
  init({
    ChatRoomSettings? chatRoomSettings,
    ChatCustomize? customize,
    Future<Map<String, dynamic>> Function(Map<String, dynamic>, ChatModel)?
        beforeMessageSent,
    Function(ChatMessage)? afterMessageSent,
    Future<void> Function(String)? beforeSingleChatRoomCreate,
    Future<void> Function(ChatRoom)? beforeGroupChatRoomJoin,
  }) {
    // dog('--> ChatService.init()');
    this.chatRoomSettings = chatRoomSettings ?? this.chatRoomSettings;
    this.customize = customize ?? this.customize;

    this.afterMessageSent = afterMessageSent;
    this.beforeMessageSent = beforeMessageSent;

    this.beforeSingleChatRoomCreate = beforeSingleChatRoomCreate;
    this.beforeGroupChatRoomJoin = beforeGroupChatRoomJoin;
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
  /// 채팅방을 보여준다. 채팅방을 입장 할 때에는 [otherUid], [roomId] 또는 [room] 중 하나를
  /// 전달하면 된다.
  ///
  /// [otherUid] 는 1:1 채팅방에서 다른 사용자의 uid 이다.
  ///
  /// [roomId] 는 채팅방의 id 이다.
  ///
  /// [room] 는 채팅방의 정보이다. [room] 을 전달하면 보다 빠르게 화면을 보여 줄 수 있다.
  Future showChatRoomScreen({
    required BuildContext context,
    String? otherUid,
    String? roomId,
    ChatRoom? room,
  }) async {
    if (notLoggedIn) {
      final re = await UserService.instance.loginRequired!(
          context: context,
          action: 'showChatRoomScreen',
          data: {
            'uid': otherUid,
            'roomId': roomId,
            'room': room,
          });
      if (re != true) return;
    }

    /// 채팅방 입장을 할 때, DB 업데이트를 하므로, 메시지를 보낼 때에는 해제 계산이 되어져 있다.
    ///

    /// Check if it hits limit except the user is admin
    if (isAdmin == false) {
      if (await ActionLogService.instance.chatJoin.isOverLimit(
        roomId: room?.id ?? roomId ?? singleChatRoomId(otherUid!),
      )) return;
    }

    if (context.mounted) {
      return showGeneralDialog(
        context: context,
        pageBuilder: (context, animation, secondaryAnimation) =>
            DefaultChatRoomScreen(
          uid: otherUid,
          roomId: roomId,
          room: room,
        ),
      );
    }
  }

  /// Show a dialog to create a chat room.
  ///
  /// [authRequired] is used to restrict the access to the chat room for authenticated users only.
  /// If [authRequired] is true, the user must authenticate before joining this chat room.
  Future<ChatRoom?> showChatRoomCreate({
    required BuildContext context,
    bool showAuthRequiredOption = false,
  }) async {
    if (notLoggedIn) {
      UserService.instance.loginRequired!(
        context: context,
        action: 'showChatRoomCreate',
        data: {},
      );
      return null;
    }

    return await showDialog<ChatRoom?>(
      context: context,
      builder: (_) =>
          customize.chatRoomEditDialogBuilder?.call(context: context) ??
          const DefaultChatRoomEditDialog(
              // showAuthRequiredOption: showAuthRequiredOption ||
              //     chatRoomSettings.enableVerifiedUserOption!,
              ),
    );
  }

  Future showChatRoomSettings({
    required BuildContext context,
    required String roomId,
  }) async {
    return await showDialog<ChatRoom?>(
        context: context,
        builder: (_) {
          return customize.chatRoomEditDialogBuilder
                  ?.call(context: context, roomId: roomId) ??
              DefaultChatRoomEditDialog(roomId: roomId);
        });
  }

  /// Display a dialog to invite a user to a chat room.
  Future showInviteScreen({
    required BuildContext context,
    required ChatRoom room,
  }) async {
    return await showGeneralDialog<ChatRoom?>(
      context: context,
      pageBuilder: (_, __, ___) =>
          customize.chatRoomInviteScreen?.call(room: room) ??
          DefaultChatRoomInviteScreen(room: room),
    );
  }

  Future showUserListScreen({
    required BuildContext context,
    required ChatRoom room,
  }) async {
    return await showGeneralDialog(
      context: context,
      pageBuilder: (_, __, ___) =>
          customize.chatRoomUserListScreen?.call(room: room) ??
          DefaultChatRoomUserListScreen(
            room: room,
          ),
    );
  }

  Future showBlockedUserListScreen({
    required BuildContext context,
    required ChatRoom room,
  }) async {
    return await showGeneralDialog(
      context: context,
      pageBuilder: (_, __, ___) =>
          customize.chatRoomBlockedUserListScreen?.call(room: room) ??
          DefaultChatRoomBlockedUserListScreen(
            room: room,
          ),
    );
  }

  /// Set password for the chat room
  ///
  /// [roomId] is the chat room id.
  ///
  /// [password] is the password to set. If it is null, the password will be removed.
  Future setRoomPassword({
    required String roomId,
    required String? password,
  }) async {
    await settingRef(roomId).child('password').set(password);
  }

  Future<String?> getRoomPassword({required String roomId}) async {
    final snapshot = await settingRef(roomId).child('password').get();
    return snapshot.value as String?;
  }
}
