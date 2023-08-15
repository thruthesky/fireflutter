import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/models/chat_room_model.dart';
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
    final Stream<DocumentSnapshot<Object?>> roomStream =
        ChatService.instance.roomDoc(widget.room.id).snapshots();
    return StreamBuilder<DocumentSnapshot<Object?>>(
      stream: roomStream,
      builder: (BuildContext context,
          AsyncSnapshot<DocumentSnapshot<Object?>> snapshot) {
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
        final ChatRoomModel roomSnapshot =
            ChatRoomModel.fromDocumentSnapshot(snapshot.data!);
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
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20), // TODO customizable ui
                      ),
                      if (roomSnapshot.rename[UserService.instance.uid] !=
                          null) ...[
                        Text(
                            '(${roomSnapshot.rename[UserService.instance.uid]})'),
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
              if (!ChatService.instance.isMaster(
                  room: roomSnapshot, uid: ChatService.instance.uid)) ...[
                LeaveButton(
                  room: roomSnapshot,
                ),
              ],
              InviteUserButton(
                room: roomSnapshot,
              ),
              ChatSettingsButton(
                room: roomSnapshot,
              ),
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
