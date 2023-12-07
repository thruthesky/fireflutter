import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class RChatRoomEditDialog extends StatefulWidget {
  const RChatRoomEditDialog({super.key});

  @override
  State<RChatRoomEditDialog> createState() => _RChatRoomEditDialogState();
}

class _RChatRoomEditDialogState extends State<RChatRoomEditDialog> {
  bool open = false;
  final roomNameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('room create'),
          TextField(
            controller: roomNameController,
            decoration: const InputDecoration(
              labelText: 'Room name',
            ),
          ),
          SwitchListTile(
            value: open,
            onChanged: (v) => setState(() => open = v),
            title: const Text('Open group chat'),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            DatabaseReference roomRef = rtdb.ref('chat-rooms').push();
            roomRef.set({
              'name': roomNameController.text,
              'isGroupChat': true,
              'isOpenGroupChat': open,
              'createdAt': DateTime.now().millisecondsSinceEpoch,
              'users': {
                myUid: true,
              },
              'testval': 1,
            });

            final room = RChatRoomModel.fromSnapshot(await getSnapshot(roomRef.path));
            await RChat.joinRoom(room: room);

            if (context.mounted) {
              Navigator.pop(context, room);
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
