import 'package:fireflutter/src/models/chat_room_model.dart';
import 'package:fireflutter/src/services/chat.service.dart';
import 'package:flutter/material.dart';

class ChatRoomDefaultRoomNameSettingListTile extends StatelessWidget {
  ChatRoomDefaultRoomNameSettingListTile({
    super.key,
    required this.room,
  });

  final ChatRoomModel room;

  final defaultChatRoomName = TextEditingController();

  @override
  Widget build(BuildContext context) {
    defaultChatRoomName.text = room.name;
    return ListTile(
      title: const Text('Default Chat Room Name'),
      subtitle: TextFormField(
        controller: defaultChatRoomName,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(
            hintText: 'Enter the default chat room name.'),
        onFieldSubmitted: (value) async {
          if (value.isNotEmpty) {
            await ChatService.instance.updateRoomSetting(
              room: room,
              setting: 'name',
              value: value,
            );
          }
        },
      ),
    );
  }
}
