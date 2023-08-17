import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/models/room.dart';
import 'package:flutter/material.dart';

class ChatRoomMenuDialog extends StatefulWidget {
  const ChatRoomMenuDialog({
    super.key,
    required this.room,
    this.otherUser,
  });

  final Room room;
  final User? otherUser;

  @override
  State<ChatRoomMenuDialog> createState() => _ChatRoomMenuScreenState();
}

class _ChatRoomMenuScreenState extends State<ChatRoomMenuDialog> {
  @override
  Widget build(BuildContext context) {
    final Stream<DocumentSnapshot<Object?>> roomStream = ChatService.instance.roomDoc(widget.room.id).snapshots();
    return StreamBuilder<DocumentSnapshot<Object?>>(
      stream: roomStream,
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot<Object?>> snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(),
            body: const Text('Something went wrong'),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(),
            body: const Text('Loading...'),
          );
        }
        final Room room = Room.fromDocumentSnapshot(snapshot.data!);
        // TODO different menu for single chat room and group chat room
        // I think it doesn't make sense to see it like a members list.
        // Instead it should only provide the other user profile
        // plus Settings
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(tr.chat.roomMenu),
          ),
          body: ListView(
            children: [
              if (room.group) ...[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        room.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20), // TODO customizable ui
                      ),
                      if (room.rename[UserService.instance.uid] != null) ...[
                        Text('(${room.rename[UserService.instance.uid]})'),
                      ],
                    ],
                  ),
                ),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(widget.otherUser!.displayName),
                ),
              ],
              if (room.isGroupChat)
                TextButton(
                  onPressed: () {
                    showGeneralDialog(
                      context: context,
                      pageBuilder: (context, _, __) => Scaffold(
                        appBar: AppBar(
                          title: const Text('Invite User'),
                        ),
                        body: ChatRoomUserInviteDialog(room: room),
                      ),
                    );
                  },
                  child: const Text('Invite User'),
                ),
              if (!ChatService.instance.isMaster(room: room, uid: ChatService.instance.uid)) ...[
                LeaveButton(room: room),
              ],
              ChatSettingsButton(room: room),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0, right: 16.0),
                    child: Text('Members'),
                  ),
                  ChatRoomMembersListView(room: room),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
