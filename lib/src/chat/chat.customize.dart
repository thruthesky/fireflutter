import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ChatCustomize {
  /// Customization for chat room menu inside DefaultChatRoomScreen
  final Widget Function(ChatModel chat)? chatRoomMenu;

  /// Customization for chat room invite button inside DefaultChatRoomScreen
  final Widget Function(ChatRoom chatRoom)? chatRoomInviteButton;

  /// Customization to override/replace the DefaultChatRoomScreen
  /// This will replace the whole chat room screen for ChatService.showChatRoom()
  /// You may need to include Scaffold, AppBar, etc.
  final Widget Function({
    String? uid,
    String? roomId,
    ChatRoom? room,
  })? chatRoomScreen;

  const ChatCustomize({
    this.chatRoomMenu,
    this.chatRoomInviteButton,
    this.chatRoomScreen,
  });
}
