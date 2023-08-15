import 'package:fireflutter/src/models/chat_room_model.dart';
import 'package:fireflutter/src/services/chat.service.dart';
import 'package:flutter/material.dart';

class ChatRoomPasswordSettingListTile extends StatefulWidget {
  const ChatRoomPasswordSettingListTile({
    super.key,
    required this.room,
  });

  final ChatRoomModel room;

  @override
  State<ChatRoomPasswordSettingListTile> createState() =>
      _ChatRoomPasswordSettingListTileState();
}

class _ChatRoomPasswordSettingListTileState
    extends State<ChatRoomPasswordSettingListTile> {
  final password = TextEditingController();

  bool hidePassword = true;

  @override
  Widget build(BuildContext context) {
    password.text = widget.room.password ?? '';
    return ListTile(
      title: const Text('Password'),
      subtitle: TextFormField(
        controller: password,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          hintText: 'Enter the password for chat room.',
          suffixIcon: IconButton(
            icon: Icon(hidePassword ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() {
                hidePassword = !hidePassword;
              });
            },
          ),
        ),
        onFieldSubmitted: (value) async {
          if (value.isNotEmpty) {
            // TODO review this because user may want to remove the password
            // TODO testing
            await ChatService.instance.updateRoomSetting(
              room: widget.room,
              setting: 'password',
              value: value,
            );
          }
        },
        obscureText: hidePassword,
        enableSuggestions: false,
        autocorrect: false,
      ),
    );
  }
}
