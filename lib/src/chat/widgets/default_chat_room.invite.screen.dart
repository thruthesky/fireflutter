import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class DefaultChatRoomInviteScreen extends StatelessWidget {
  const DefaultChatRoomInviteScreen({
    super.key,
    required this.room,
  });

  final ChatRoom room;

  /// get list of uids of members
  List<String> get memberUids => (room.users ?? {}).keys.toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('친구 초대'),
      ),
      body: FirebaseDatabaseListView(
        query: User.usersRef.orderByChild('order'),
        itemBuilder: (context, snapshot) {
          final user = User.fromSnapshot(snapshot);
          if (memberUids.contains(user.uid)) {
            return const SizedBox.shrink();
          }
          return ListTile(
            leading: UserAvatar(uid: user.uid),
            title: Text(user.displayName),
            subtitle: Text(user.stateMessage),
            trailing: const Icon(Icons.add),
            onTap: () async {
              await room.invite(user.uid);
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
          );
        },
      ),
    );
  }
}
