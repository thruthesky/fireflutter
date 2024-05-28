import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class DefaultChatRoomUserListScreen extends StatelessWidget {
  const DefaultChatRoomUserListScreen({
    super.key,
    required this.room,
  });

  final ChatRoom room;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
      ),
      body: FirebaseDatabaseQueryBuilder(
        query: ChatService.instance.roomsRef.child(room.id).child(Field.users),
        pageSize: 50,
        builder: (context, snapshot, _) {
          if (snapshot.isFetching) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Text('Something went wrong! ${snapshot.error}');
          }
          if (snapshot.hasMore == false && snapshot.docs.isEmpty) {
            return const Text('No members!');
          }
          return ListView.builder(
            itemCount: snapshot.docs.length,
            itemBuilder: (context, index) {
              final member = User.get(snapshot.docs[index].key!);
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
                        final User user = snapshot.data as User;
                        return ListTile(
                          leading: UserAvatar(uid: user.uid),
                          title: Row(
                            children: [
                              Text(user.displayName),
                              if (room.isMasterUser(user.uid))
                                const Text(' (Master)'),
                            ],
                          ),
                          subtitle: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (user.stateMessage.isEmpty == false)
                                Text(user.stateMessage.or('....')),
                            ],
                          ),
                        );
                        // return UserTile(
                        //   user: snapshot.data as User,
                        //   displayStateMessage: true,
                        // );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
