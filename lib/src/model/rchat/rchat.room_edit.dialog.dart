import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

typedef RChatRoomEditDialogText = ({
  String title,
  String name,
  String description,
  String create,
  String cancel,
  String openChat,
  String errorCompleteForm,
});

class RChatRoomEditDialog extends StatefulWidget {
  const RChatRoomEditDialog({super.key, this.texts});

  final RChatRoomEditDialogText? texts;

  @override
  State<RChatRoomEditDialog> createState() => _RChatRoomEditDialogState();
}

class _RChatRoomEditDialogState extends State<RChatRoomEditDialog> {
  bool open = false;
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  RChatRoomEditDialogText? get texts => widget.texts;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 24),
          Text(texts?.title ?? 'New chat', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: texts?.name ?? 'Room name',
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: texts?.description ?? 'Description',
              ),
            ),
          ),
          SwitchListTile(
            value: open,
            onChanged: (v) => setState(() => open = v),
            title: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                texts?.openChat ?? 'Open chat',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(texts?.cancel ?? 'Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (nameController.text.isEmpty || descriptionController.text.isEmpty) {
              alert(context: context, title: '', message: texts?.errorCompleteForm ?? 'Please complete the form');
              return;
            }
            DatabaseReference roomRef = rtdb.ref('chat-rooms').push();
            roomRef.set({
              'name': nameController.text,
              'description': descriptionController.text,
              'isGroupChat': true,
              'isOpenGroupChat': open,
              'createdAt': DateTime.now().millisecondsSinceEpoch,
              'master': myUid,
              'users': {
                myUid: true,
              },
            });

            final room = RChatRoomModel.fromSnapshot(await getSnapshot(roomRef.path));
            await RChat.joinRoom(room: room);

            if (context.mounted) {
              Navigator.pop(context, room);
            }
          },
          child: Text(texts?.create ?? 'Create'),
        ),
      ],
    );
  }
}
