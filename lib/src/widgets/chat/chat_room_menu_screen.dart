import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/models/room.dart';
import 'package:flutter/material.dart';

class ChatRoomMenuScreen extends StatefulWidget {
  const ChatRoomMenuScreen({
    super.key,
    required this.room,
    this.otherUser,
  });

  final Room room;
  final User? otherUser;

  @override
  State<ChatRoomMenuScreen> createState() => _ChatRoomMenuScreenState();
}

class _ChatRoomMenuScreenState extends State<ChatRoomMenuScreen> {
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
        final Room roomSnapshot = Room.fromDocumentSnapshot(snapshot.data!);
        // TODO different menu for single chat room and group chat room
        // I think it doesn't make sense to see it like a members list.
        // Instead it should only provide the other user profile
        // plus Settings
        return Scaffold(
          appBar: AppBar(
            title: const Text('Chat Room'),
          ),
          body: ListView(
            children: [
              if (roomSnapshot.group) ...[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        roomSnapshot.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20), // TODO customizable ui
                      ),
                      if (roomSnapshot.rename[UserService.instance.uid] != null) ...[
                        Text('(${roomSnapshot.rename[UserService.instance.uid]})'),
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
              if (roomSnapshot.isGroupChat) InviteUserButton(room: roomSnapshot),
              if (!ChatService.instance.isMaster(room: roomSnapshot, uid: ChatService.instance.uid)) ...[
                LeaveButton(room: roomSnapshot),
              ],
              ChatSettingsButton(room: roomSnapshot),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0, right: 16.0),
                    child: Text('Members'),
                  ),
                  ChatRoomMembersListView(room: roomSnapshot),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
