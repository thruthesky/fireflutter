import 'package:fireflutter/src/models/chat_room_model.dart';
import 'package:fireflutter/src/services/chat.service.dart';
import 'package:fireflutter/src/widgets/chat/chat_room_default_room_name_setting.dart';
import 'package:fireflutter/src/widgets/chat/chat_room_maximum_users_setting_list_tile.dart';
import 'package:fireflutter/src/widgets/chat/chat_room_open_setting_list_tile.dart';
import 'package:flutter/material.dart';

class ChatRoomSettingsScreen extends StatelessWidget {
  const ChatRoomSettingsScreen({
    super.key,
    required this.room,
  });

  final ChatRoomModel room;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          if (ChatService.instance
                  .isMaster(room: room, uid: ChatService.instance.uid) &&
              room.group) ...[
            ChatRoomOpenSettingListTile(
              room: room,
            ),
            ChatRoomMaximumUsersSettingListTile(
              room: room,
            ),
            ChatRoomDefaultRoomNameSettingListTile(
              room: room,
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
      ),
    );
  }
}
