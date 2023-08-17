import 'package:fireflutter/src/models/room.dart';
import 'package:fireflutter/src/services/chat.service.dart';
import 'package:flutter/material.dart';

class ChatRoomPasswordSettingListTile extends StatefulWidget {
  const ChatRoomPasswordSettingListTile({
    super.key,
    required this.room,
  });

  final Room room;

  @override
  State<ChatRoomPasswordSettingListTile> createState() => _ChatRoomPasswordSettingListTileState();
}

class _ChatRoomPasswordSettingListTileState extends State<ChatRoomPasswordSettingListTile> {
  final password = TextEditingController();
  bool hidePassword = true;

  @override
  void initState() {
    super.initState();
    password.text = widget.room.password ?? '';
  }

  @override
  Widget build(BuildContext context) {
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
                debugPrint(password.text);
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
