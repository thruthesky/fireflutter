import 'package:fireflutter/src/models/chat_room_model.dart';
import 'package:fireflutter/src/services/chat.service.dart';
import 'package:flutter/material.dart';

class ChatRoomDefaultRoomNameSettingListTile extends StatefulWidget {
  const ChatRoomDefaultRoomNameSettingListTile({
    super.key,
    required this.room,
    this.onUpdateChatRoomName,
  });

  final ChatRoomModel room;
  final Function(ChatRoomModel updatedRoom)? onUpdateChatRoomName;

  @override
  State<ChatRoomDefaultRoomNameSettingListTile> createState() =>
      _ChatRoomDefaultRoomNameSettingListTileState();
}

class _ChatRoomDefaultRoomNameSettingListTileState
    extends State<ChatRoomDefaultRoomNameSettingListTile> {
  ChatRoomModel? _roomState;
  final defaultChatRoomName = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _roomState ??= widget.room;
    defaultChatRoomName.text = _roomState?.name ?? '';
    return ListTile(
      title: const Text('Default Chat Room Name'),
      subtitle: TextFormField(
        controller: defaultChatRoomName,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(
            hintText: 'Enter the default chat room name.'),
        onFieldSubmitted: (value) async {
          _roomState = await ChatService.instance.updateRoomSetting(
            room: _roomState!,
            setting: 'name',
            value: value,
          );
          if (mounted) setState(() {});
          widget.onUpdateChatRoomName?.call(_roomState!);
        },
      ),
    );
  }
}
