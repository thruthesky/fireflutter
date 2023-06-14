import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class Chat extends StatefulWidget {
  const Chat({
    super.key,
    this.otherUserUid,
    required this.onTap,
  });

  final void Function(ChatRoomModel) onTap;
  final String? otherUserUid;

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  get chatRoomsQuery => FirebaseDatabase.instance.ref('chat/rooms/${UserService.uid}').orderByChild('updatedAt');

  @override
  void initState() {
    super.initState();
    if (widget.otherUserUid != null) {
      ChatService.getRoom(widget.otherUserUid!).then(openChatRoom);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FirebaseDatabaseListView(
      query: chatRoomsQuery,
      itemBuilder: (context, snapshot) {
        final room = ChatRoomModel.fromSnapshot(snapshot);
        print(room);
        final otherUserUid = snapshot.key!;
        if (room.lastMessage.senderUid == '') {
          return const SizedBox.shrink();
        }
        // TODO get user details
        return GestureDetector(
          onTap: () {
            widget.onTap(room);
            openChatRoom(room);
          },
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                FutureBuilder(
                  future: UserService.getProfilePhotoUrl(otherUserUid),
                  builder: (context, snapshot) {
                    log('Gotcha! $snapshot');
                    if (snapshot.data == null || snapshot.data == '') {
                      log('Oh no! Null'); // means the user document was not found
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                        ),
                      );
                    }
                    final photoUrl = snapshot.data as String;

                    log('PhotoUrl! $photoUrl');
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        backgroundImage: CachedNetworkImageProvider(photoUrl),
                      ),
                    );
                  },
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sender: $otherUserUid'),
                      Text(
                        'Last Message: ${room.lastMessage.text}',
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Updated At: ${room.updatedAt}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios),
              ],
            ),
          ),
        );
      },
    );
  }

  openChatRoom(ChatRoomModel room) {
    showGeneralDialog(
      context: context,
      pageBuilder: (_, __, ___) {
        return ChatRoom(
          room: room,
        );
      },
    );
  }
}
