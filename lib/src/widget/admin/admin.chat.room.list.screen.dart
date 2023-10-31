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
        itemExtent: 80,
        query: chatCol,
        itemBuilder: (context, snapshot) {
          final room = Room.fromDocumentSnapshot(snapshot);
          return InkWell(
            onTap: () {
              AdminService.instance.showChatRoomDetails(context, room: room);
            },
            child: ChatRoomListTile(
              padding: const EdgeInsets.fromLTRB(sizeMd, 0, sizeMd, 0),
              room: room,
              avatarBuilder: (room) {
                return SizedBox(
                  width: 40,
                  height: 40,
                  child: Stack(
                    children: [
                      UserAvatar(
                        uid: room.users.first,
                        size: 40 / 1.6,
                        radius: 10,
                        borderWidth: 1,
                        borderColor: Colors.grey.shade300,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: UserAvatar(
                            uid: room.users.last,
                            size: 40 / 1.4,
                            radius: 10,
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
                      onLoading: const CircularProgressIndicator.adaptive(),
                    ),
                    UserDoc(
                      uid: room.users.last,
                      builder: (_) {
                        return Text(_.getDisplayName, style: Theme.of(context).textTheme.bodyMedium);
                      },
                      onLoading: const CircularProgressIndicator.adaptive(),
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
          );
        },
      ),
    );
  }
}
