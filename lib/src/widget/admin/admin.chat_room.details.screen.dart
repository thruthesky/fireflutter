import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class AdminChatRoomDetailsScreen extends StatelessWidget {
  const AdminChatRoomDetailsScreen({
    super.key,
    required this.room,
  });

  final Room room;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Room Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(sizeSm, sizeSm, sizeSm, 0),
              child: Text('Room ID: ${room.roomId}', style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
            if (room.name.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(sizeSm, sizeSm, sizeSm, 0),
                child: Text('Room Name: ${room.name}'),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(sizeSm, sizeSm, sizeSm, 0),
              child: Text('Last Activity: ${room.lastMessage?.createdAt ?? room.createdAt}'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(sizeSm, sizeSm, sizeSm, 0),
              child: Text(
                  'Room Type: ${room.isGroupChat ? "Group Chat" : "1:1 Chat"}, ${room.open ? "Open Room" : "Private Room"}'),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(sizeSm, sizeSm, sizeSm, 0),
              child: Text('Members:'),
            ),
            for (String uid in room.users)
              UserDoc(
                uid: uid,
                builder: (user) {
                  String userRoomAdminDetails = room.master == user.uid
                      ? "(Master)"
                      : room.moderators.contains(user.uid)
                          ? "(Moderator)"
                          : "";
                  return ListTile(
                    leading: UserAvatar(user: user),
                    title: Text('${user.name} $userRoomAdminDetails'),
                    subtitle: Text('${user.type} | ${user.uid}'),
                    onTap: () => UserService.instance.showPublicProfileScreen(context: context, user: user),
                  );
                },
              )
          ],
        ),
      ),
    );
  }
}
