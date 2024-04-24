import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ChatCustomize {
  /// Customization for chat room menu inside DefaultChatRoomScreen
  final Widget Function(ChatModel chat)? chatRoomMenu;

  /// Customization for chat room invite button inside DefaultChatRoomScreen
  final Widget Function(ChatRoom chatRoom)? chatRoomInviteButton;

  /// Customization for chat room edit dialog inside DefaultChatRoomScreen
  final Widget Function({
    required BuildContext context,
    String? roomId,
  })? chatRoomEditDialogBuilder;

  final Widget Function(ChatModel chat)? messageInputBoxPrefixIconBuilder;

  /// Customization for chat bubble inside DefaultChatRoomScreen
  final Widget Function({
    required BuildContext context,
    required ChatMessage message,
    required Function onChange,
  })? chatBubbleBuilder;

  const ChatCustomize({
    this.chatRoomMenu,
    this.chatRoomInviteButton,
    this.chatBubbleBuilder,
    this.chatRoomEditDialogBuilder,
    this.messageInputBoxPrefixIconBuilder,
  });
}
