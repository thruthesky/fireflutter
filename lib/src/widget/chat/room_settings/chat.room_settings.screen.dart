import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ChatRoomSettingsScreen extends StatefulWidget {
  const ChatRoomSettingsScreen({
    super.key,
    required this.room,
  });

  final Room room;

  @override
  State<ChatRoomSettingsScreen> createState() => _ChatRoomSettingsScreenState();
}

class _ChatRoomSettingsScreenState extends State<ChatRoomSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final Stream<DocumentSnapshot> roomStream =
        ChatService.instance.roomDoc(widget.room.id).snapshots();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: roomStream,
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong.');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading...");
          }
          final Room roomSnapshot = Room.fromDocumentSnapshot(snapshot.data!);
          return ListView(
            children: [
              if (widget.room.group) ...[
                if (ChatService.instance.isMaster(
                    room: roomSnapshot, uid: ChatService.instance.uid)) ...[
                  ChatRoomSettingsOpenListTile(room: roomSnapshot),
                  ChatRoomSettingsMaximumUserListTile(room: roomSnapshot),
                  ChatRoomSettingsDefaultRoomNameListTile(room: roomSnapshot),
                ],
                ChatRoomSettingsRenameListTile(room: roomSnapshot),
              ],
            ],
          );
        },
      ),
    );
  }
}
