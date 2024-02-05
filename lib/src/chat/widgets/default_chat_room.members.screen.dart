import 'package:firebase_auth/firebase_auth.dart';
import 'package:fireship/fireship.dart';
import 'package:fireship/src/chat/widgets/default_chat_room.member.dialog.dart';
import 'package:flutter/material.dart';

class DefaultChatRoomMembersScreen extends StatelessWidget {
  const DefaultChatRoomMembersScreen({
    super.key,
    required this.room,
  });

  final ChatRoomModel room;

  /// A Getter to get a List of uids of the members of the room.
  List<String> get members => (room.users ?? {})
      .map((key, value) => MapEntry(key, value))
      .keys
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
      ),
      body: ListView.builder(
        itemCount: members.length,
        itemBuilder: (context, index) {
          final member = UserModel.get(members[index]);
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              final awaitUser = await member;
              if (awaitUser == null) return;
              if (!context.mounted) return;
              showDialog(
                context: context,
                builder: (context) => DefaultChatRoomMemberDialog(
                  room: room,
                  member: awaitUser,
                ),
              );
            },
            child: SizedBox(
              height: 70,
              child: FutureBuilder(
                future: member,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return UserTile(user: snapshot.data as UserModel);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
