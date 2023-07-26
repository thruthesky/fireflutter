import 'package:easychat/easychat.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, this.user});
  final UserModel? user;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatRoomListViewController controller = ChatRoomListViewController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.user != null) {
        controller.showChatRoom(context: context, user: widget.user);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Chat Friends - My Chat Rooms'),
        actions: [
          IconButton(
            onPressed: () async {
              showDialog(
                context: context,
                builder: (_) => ChatRoomCreate(
                  success: (room) {
                    Navigator.of(context).pop();
                    if (context.mounted) {
                      controller.showChatRoom(context: context, room: room);
                    }
                  },
                  cancel: () => Navigator.of(context).pop(),
                  error: () => const ScaffoldMessenger(child: Text('Error creating chat room')),
                ),
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ChatRoomListView(
        controller: controller,
        // itemBuilder: (context, room) {
        //   return ListTile(
        //       leading: const Icon(Icons.chat),
        //       title: ChatRoomListTileName(
        //         room: room,
        //         style: const TextStyle(color: Colors.blue),
        //       ),
        //       trailing: const Icon(Icons.chevron_right),
        //       onTap: () {
        //         controller.showChatRoom(context: context, room: room);
        //       });
        // },
      ),
    );
  }
}
