import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/models/room.dart';
import 'package:flutter/material.dart';

class ChatRoomMenuDialog extends StatelessWidget {
  const ChatRoomMenuDialog({
    super.key,
    required this.room,
    // this.otherUser,
  });

  final Room room;
  // final User? otherUser;

  // Stream<DocumentSnapshot<Object?>> get roomStream => ChatService.instance.roomDoc(widget.room.id).snapshots();

  bool get isMaster => ChatService.instance.isMaster(room: room, uid: ChatService.instance.uid);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(60, 60, 0, 0),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Spacer(),

                    // 즐겨찾기
                    const Icon(Icons.favorite_border),

                    // 공유
                    Icon(Platform.isAndroid ? Icons.share : Icons.ios_share_rounded),

                    // 방 나가기
                    if (isMaster == false)
                      IconButton(
                        onPressed: () {
                          ChatService.instance.leaveRoom(
                            room: room,
                          );
                          // room.leave();
                        },
                        icon: const Icon(Icons.exit_to_app),
                      ),

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
                  ],
                ),
                const SizedBox(height: 16),
                if (room.group) ...[
                  if (room.rename[UserService.instance.uid] == null)
                    Text(room.name, style: Theme.of(context).textTheme.titleLarge)
                  else ...[
                    Text(
                      room.rename[UserService.instance.uid]!,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(room.name, style: Theme.of(context).textTheme.titleSmall)
                  ],
                ] else ...[
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    // TODO 채팅방을 1:1과 그룹 메뉴로 분리 할 것.
                    child: Text('1:1 채팅방과 그룹 채팅 메뉴를  분리 할 것.'),
                  ),
                ],
                Text("${room.users.length} joined"),
                Text("Created on ${room.createdAt.toDate().toString().split(' ').first}"),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                const Text('Participants', style: TextStyle(fontSize: 18)),
                ChatRoomMembersListView(room: room),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
