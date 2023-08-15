import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/models/chat_room_model.dart';
import 'package:flutter/material.dart';

class ChatRoomAppBarTitle extends StatelessWidget {
  const ChatRoomAppBarTitle({
    super.key,
    required this.room,
  });

  final ChatRoomModel room;

  @override
  Widget build(BuildContext context) {
    if (room.group) {
      return Row(
        children: [
          const SizedBox(width: 8),
          Text(room.rename[UserService.instance.uid] ?? room.name),
        ],
      );
    } else {
      return FutureBuilder(
        future: UserService.instance.get(room.otherUserUid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('Loading...');
          }
          if (snapshot.hasData == false) {
            return const Text('Error - no user');
          }
          final user = snapshot.data as UserModel;
          return Row(
            children: [
              user.photoUrl.isEmpty
                  ? const SizedBox()
                  : CircleAvatar(
                      backgroundImage: NetworkImage(user.photoUrl),
                    ),
              const SizedBox(width: 8),
              Text(user.displayName),
            ],
          );
        },
      );
    }
  }
}
