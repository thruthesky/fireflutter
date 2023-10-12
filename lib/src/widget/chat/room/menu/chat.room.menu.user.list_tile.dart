import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ChatRoomMenuUserListTile extends StatelessWidget {
  const ChatRoomMenuUserListTile({super.key, required this.room, required this.user});

  final Room room;
  final User user;

  bool get isMaster => ChatService.instance.isMaster(room: room, uid: user.uid);
  bool get isModerator => ChatService.instance.isModerator(room: room, uid: user.uid);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        UserService.instance.showPublicProfileScreen(context: context, user: user);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(children: [
          Stack(
            children: [
              UserAvatar(user: user, size: 40),
              if (isMaster) const Icon(Icons.shield, size: 16, color: Colors.red),
              if (isModerator) const Icon(Icons.verified, size: 16, color: Colors.blue),
            ],
          ),
          const SizedBox(width: 20),
          Text(user.displayName.isNotEmpty ? user.displayName : user.name),
          const Spacer(),
          const Icon(Icons.more_vert),
        ]),
      ),
    );
  }
}
