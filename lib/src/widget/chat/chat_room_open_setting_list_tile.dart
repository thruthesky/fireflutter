import 'package:fireflutter/src/model/chat/room.dart';
import 'package:fireflutter/src/service/chat.service.dart';
import 'package:flutter/material.dart';

class ChatRoomOpenSettingListTile extends StatelessWidget {
  const ChatRoomOpenSettingListTile({
    super.key,
    required this.room,
  });

  final Room room;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text("Open Chat Room"),
      subtitle: room.open
          ? const Text("Anyone can join or invite users.")
          : const Text("Only Admins can invite users."),
      trailing: Switch(
        value: room.open,
        onChanged: (value) async {
          await ChatService.instance.updateRoomSetting(
            room: room,
            setting: 'open',
            value: value,
          );
        },
      ),
    );
  }
}
