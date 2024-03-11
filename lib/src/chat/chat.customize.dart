import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ChatCustomize {
  /// Customization for chat room menu inside DefaultChatRoomScreen
  final Widget Function(ChatModel chat)? chatRoomMenu;

  /// Customization for chat room invite button inside DefaultChatRoomScreen
  final Widget Function(ChatRoom chatRoom)? chatRoomInviteButton;

  const ChatCustomize({
    this.chatRoomMenu,
    this.chatRoomInviteButton,
  });
}
