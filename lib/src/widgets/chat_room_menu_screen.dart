import 'package:easychat/easychat.dart';
import 'package:flutter/material.dart';

class ChatRoomMenuScreen extends StatefulWidget {
  const ChatRoomMenuScreen({
    super.key,
    required this.room,
    this.otherUser,
  });

  final ChatRoomModel room;
  final UserModel? otherUser;

  @override
  State<ChatRoomMenuScreen> createState() => _ChatRoomMenuScreenState();
}

class _ChatRoomMenuScreenState extends State<ChatRoomMenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Room'),
      ),
      body: ListView(
        children: [
          if (widget.room.group) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(widget.room.name),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(widget.otherUser!.displayName),
            ),
          ],
          if (!EasyChat.instance.isMaster(room: widget.room, uid: EasyChat.instance.uid)) ...[
            LeaveButton(
              room: widget.room,
            ),
          ],
          InviteUserButton(
            room: widget.room,
            onInvite: (invitedUserUid) {
              setState(() {});
            },
          ),
          ChatSettingsButton(room: widget.room),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 16.0, right: 16.0),
                child: Text('Members'),
              ),
              ChatRoomMembersListView(room: widget.room),
            ],
          ),
        ],
      ),
    );
  }
}
