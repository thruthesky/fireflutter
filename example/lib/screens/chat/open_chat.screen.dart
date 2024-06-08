import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class OpenChatScreen extends StatefulWidget {
  static const String routeName = '/OpenChat';
  const OpenChatScreen({super.key});

  @override
  State<OpenChatScreen> createState() => _OpenChatScreenState();
}

class _OpenChatScreenState extends State<OpenChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Open Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => ChatService.instance
                .showChatRoomCreate(
                  context: context,
                )
                .then(
                  (room) => ChatService.instance.showChatRoomScreen(
                    context: context,
                    room: room,
                  ),
                ),
          ),
        ],
      ),
      body: ChatRoomListView(
        // openChat: true,
        chatRoomList: ChatRoomList.open,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (room, index) => ChatRoomListTile(room: room),
      ),
    );
  }
}
