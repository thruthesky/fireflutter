import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class AdminChatRoomListScreen extends StatefulWidget {
  static const String routeName = '/AdminChatRoomList';
  const AdminChatRoomListScreen({super.key});

  @override
  State<AdminChatRoomListScreen> createState() => _AdminChatRoomListScreenState();
}

class _AdminChatRoomListScreenState extends State<AdminChatRoomListScreen> {
  final controller = ChatRoomListViewController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('AdminChatRoomListBackButton'),
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Admin Chat Room List'),
      ),
      body: FirestoreListView(
        query: chatCol.orderBy('lastMessage.createdAt', descending: true),
        itemBuilder: (context, snapshot) {
          final room = Room.fromDocumentSnapshot(snapshot);
          return InkWell(
            onTap: () {
              AdminService.instance.showChatRoomDetails(context, room: room);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ChatRoomListTile(
                  room: room,
                  padding: const EdgeInsets.fromLTRB(sizeSm, sizeSm, sizeSm, sizeSm),
                  avatarBuilder: (room) {
                    return SizedBox(
                      width: 56,
                      height: 56,
                      child: Stack(
                        children: [
                          UserAvatar(
                            uid: room.users.first,
                            size: 56 / 1.5,
                            radius: 100,
                            borderWidth: 1,
                            borderColor: Colors.grey.shade300,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: UserAvatar(
                                uid: room.users.last,
                                size: 56 / 1.5,
                                radius: 100,
                                borderWidth: 1,
                                borderColor: Colors.white),
                          ),
                        ],
                      ),
                    );
                  },
                  contentBuilder: (room) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        UserDoc(
                          uid: room.users.first,
                          builder: (_) {
                            return Text(_.getDisplayName, style: Theme.of(context).textTheme.bodyMedium);
                          },
                          onLoading: const CircularProgressIndicator(),
                        ),
                        UserDoc(
                          uid: room.users.last,
                          builder: (_) {
                            return Text(_.getDisplayName, style: Theme.of(context).textTheme.bodyMedium);
                          },
                          onLoading: const CircularProgressIndicator(),
                        ),
                        Text(
                          (room.lastMessage?.text ?? '').replaceAll("\n", ' '),
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                        ),
                      ],
                    );
                  },
                ),
                const Divider(
                  height: 5,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
