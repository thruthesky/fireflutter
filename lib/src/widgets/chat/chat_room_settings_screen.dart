import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/src/models/chat_room_model.dart';
import 'package:fireflutter/src/services/chat.service.dart';
import 'package:fireflutter/src/widgets/chat/chat_room_default_room_name_setting.dart';
import 'package:fireflutter/src/widgets/chat/chat_room_maximum_users_setting_list_tile.dart';
import 'package:fireflutter/src/widgets/chat/chat_room_open_setting_list_tile.dart';
import 'package:flutter/material.dart';

class ChatRoomSettingsScreen extends StatefulWidget {
  const ChatRoomSettingsScreen({
    super.key,
    required this.room,
  });

  final ChatRoomModel room;

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
          final ChatRoomModel roomSnapshot =
              ChatRoomModel.fromDocumentSnapshot(snapshot.data!);
          return ListView(
            children: [
              if (ChatService.instance.isMaster(
                      room: roomSnapshot, uid: ChatService.instance.uid) &&
                  widget.room.group) ...[
                ChatRoomOpenSettingListTile(
                  room: roomSnapshot,
                ),
                ChatRoomMaximumUsersSettingListTile(
                  room: roomSnapshot,
                ),
                ChatRoomDefaultRoomNameSettingListTile(
                  room: roomSnapshot,
                ),
              ],
              // ! Still Ongoing
              // TODO Proceed here christian
              const ListTile(
                title: Text("Rename Chat Room"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("This will rename the chat room only on your view."),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
