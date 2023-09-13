import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ChatRoomCustomize {
  PreferredSizeWidget? Function({Room? room, User? user})?
      chatRoomAppBarBuilder;
  Function(BuildContext, Room)? onChatRoomFileUpload;
}
