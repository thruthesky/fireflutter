import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ChatCustomize {
  PreferredSizeWidget? Function({Room? room, User? user})?
      chatRoomAppBarBuilder;
  Function(BuildContext, Room)? onChatRoomFileUpload;

  /// Customizing the chat room open.
  ///
  /// You can check user permission and etc. For instance, if the user did not
  /// pay for the chat room, you can show the payment screen. Or if the user
  /// did not complete his profile, you can show the profile screen.
  Function({required BuildContext context, Room? room, User? user})?
      showChatRoom;

  /// Customizing the chat message list top.
  ///
  /// You can display any widget on the top of the chat message list.
  ///
  ///
  /// [firstPageFilled] If there are enough messages to fill the first page, this will be true.
  /// Or it will be false if there are less messages than the number of pageSize.
  /// Use this to determine for your need. For instance, if there are less messages than the number of pageSize,
  /// You may display user profile and link it to user public profile screen.
  Widget Function(BuildContext, String roomId, bool firstPageFilled)?
      chatMessageListTopBuilder;

  Widget Function(Room? room)? chatRoomMessageBoxBuilder;

  ChatCustomize({
    this.chatRoomAppBarBuilder,
    this.onChatRoomFileUpload,
    this.showChatRoom,
    this.chatMessageListTopBuilder,
    this.chatRoomMessageBoxBuilder,
  });
}
