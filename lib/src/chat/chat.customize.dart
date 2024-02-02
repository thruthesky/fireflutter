import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class ChatCustomize {
  final Widget Function(ChatModel chat)? chatRoomMenu;

  const ChatCustomize({
    this.chatRoomMenu,
  });
}
