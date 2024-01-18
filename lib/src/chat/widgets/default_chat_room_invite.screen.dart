import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class DefaultChatRoomInviteScreen extends StatelessWidget {
  const DefaultChatRoomInviteScreen({
    super.key,
    required this.room,
  });

  final ChatRoomModel room;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('친구 초대'),
      ),
      body: FirebaseDatabaseListView(
        query: Ref.users.orderByChild('order'),
        itemBuilder: (context, snapshot) {
          final user = UserModel.fromSnapshot(snapshot);
          return ListTile(
            leading: UserAvatar(uid: user.uid),
            title: Text(user.displayName ?? ''),
            subtitle: user.stateMessage == null
                ? null
                : Text(user.stateMessage ?? ''),
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
