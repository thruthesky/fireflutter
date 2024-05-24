import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  static const String routeName = '/Chat';
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
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
        query: ChatService.instance.joinsRef
            .child(myUid!)
            .orderByChild(Field.order),
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (room, index) => ChatRoomListTile(room: room),
      ),
    );
  }
}
