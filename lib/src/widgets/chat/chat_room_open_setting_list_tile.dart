import 'package:fireflutter/src/models/chat_room_model.dart';
import 'package:fireflutter/src/services/chat.service.dart';
import 'package:flutter/material.dart';

class ChatRoomOpenSettingListTile extends StatefulWidget {
  const ChatRoomOpenSettingListTile({
    super.key,
    required this.room,
    this.onToggleOpen,
  });

  final ChatRoomModel room;
  final Function(ChatRoomModel updatedRoom)? onToggleOpen;

  @override
  State<ChatRoomOpenSettingListTile> createState() =>
      _ChatRoomOpenSettingListTileState();
}

class _ChatRoomOpenSettingListTileState
    extends State<ChatRoomOpenSettingListTile> {
  ChatRoomModel? _roomState;

  @override
  Widget build(BuildContext context) {
    _roomState ??= widget.room;
    return ListTile(
      title: const Text("Open Chat Room"),
      subtitle: const Text("Anyone can join or invite users."),
      trailing: Switch(
        value: _roomState!.open,
        onChanged: (value) async {
          _roomState = await ChatService.instance.updateRoomSetting(
            room: _roomState!,
            setting: 'open',
            value: value,
          );
          if (mounted) setState(() {});
          widget.onToggleOpen?.call(_roomState!);
        },
      ),
    );
  }
}
