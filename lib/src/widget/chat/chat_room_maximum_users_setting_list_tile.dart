import 'package:fireflutter/src/model/chat/room.dart';
import 'package:fireflutter/src/service/chat.service.dart';
import 'package:flutter/material.dart';

class ChatRoomMaximumUsersSettingListTile extends StatefulWidget {
  const ChatRoomMaximumUsersSettingListTile({
    super.key,
    required this.room,
    this.onUpdateMaximumNoOfUsers,
  });

  final Room room;
  final Function(Room updatedRoom)? onUpdateMaximumNoOfUsers;

  @override
  State<ChatRoomMaximumUsersSettingListTile> createState() =>
      _ChatRoomMaximumUsersSettingListTileState();
}

class _ChatRoomMaximumUsersSettingListTileState
    extends State<ChatRoomMaximumUsersSettingListTile> {
  final maxNumberOfUsers = TextEditingController();

  @override
  Widget build(BuildContext context) {
    maxNumberOfUsers.text = "${widget.room.maximumNoOfUsers}";
    return ListTile(
      title: const Text("Maximum Number of Users"),
      subtitle: TextFormField(
        controller: maxNumberOfUsers,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(
            hintText: 'Enter the limit number of user who can join.'),
        onFieldSubmitted: (value) async {
          await ChatService.instance.updateRoomSetting(
            room: widget.room,
            setting: 'maximumNoOfUsers',
            value: value.isNotEmpty ? int.parse(value) : null,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    maxNumberOfUsers.dispose();
    super.dispose();
  }
}
