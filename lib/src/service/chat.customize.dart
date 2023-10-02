import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ChatCustomize {
  PreferredSizeWidget? Function({Room? room, User? user})? chatRoomAppBarBuilder;
  Function(BuildContext, Room)? onChatRoomFileUpload;

  /// Customizing the chat room open.
  ///
  /// You can check user permission and etc. For instance, if the user did not
  /// pay for the chat room, you can show the payment screen. Or if the user
  /// did not complete his profile, you can show the profile screen.
  Function({required BuildContext context, Room? room, User? user})? showChatRoom;

  ChatCustomize({
    this.chatRoomAppBarBuilder,
    this.onChatRoomFileUpload,
    this.showChatRoom,
  });
}
