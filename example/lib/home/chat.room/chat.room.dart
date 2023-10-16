import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:new_app/page.essentials/app.bar.dart';

class ChatRoom extends StatefulWidget {
  static const String routeName = '/ChatRoom';
  const ChatRoom({super.key});

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final ChatRoomListViewController controller = ChatRoomListViewController();

  @override
  void initState() {
    super.initState();
    ChatService.instance.customize.chatRoomAppBarBuilder =
        ({room, user}) => customAppBar(context, room);
  }

  @override
  Widget build(BuildContext context) {
    return ChatRoomListView(
      controller: controller,
      singleChatOnly: false,
      itemBuilder: (context, room) => ChatRoomListTile(
        room: room,
        onTap: () {
          // ChatService.instance.showChatRoom(context: context);
          controller.showChatRoom(context: context, room: room);
        },
      ),
    );
  }
}
