import 'package:easychat/easychat.dart';
import 'package:flutter/material.dart';

class ChatRoomMembersListView extends StatefulWidget {
  const ChatRoomMembersListView({
    super.key,
    required this.room,
  });

  final ChatRoomModel room;

  @override
  State<ChatRoomMembersListView> createState() => _ChatRoomMembersListViewState();
}

class _ChatRoomMembersListViewState extends State<ChatRoomMembersListView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: widget.room.users.length,
      itemBuilder: (context, index) {
        return FutureBuilder(
          future: EasyChat.instance.getUser(widget.room.users[index]),
          builder: (context, userSnapshot) {
            return ListTile(
              title: Text(userSnapshot.data?.displayName ?? ''),
              // subtitle: Text(userSnapshot.data?.uid ?? ''),
              subtitle: Text(widget.room.master == userSnapshot.data?.uid
                  ? 'Master'
                  : widget.room.moderators.contains(userSnapshot.data?.uid)
                      ? 'Moderator'
                      : ''),
              leading: (userSnapshot.data?.photoUrl ?? '').isEmpty
                  ? null
                  : CircleAvatar(
                      backgroundImage: NetworkImage(userSnapshot.data!.photoUrl),
                    ),
              onTap: () {
                final user = userSnapshot.data;
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(user?.displayName ?? user?.uid ?? ''),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (EasyChat.instance.canRemove(room: widget.room, userUid: user!.uid)) ...[
                            TextButton(
                              child: const Text('Remove from the Group'),
                              onPressed: () {
                                EasyChat.instance.removeUserFromRoom(
                                  room: widget.room,
                                  uid: user.uid,
                                  callback: () {
                                    setState(() {
                                      widget.room.users.remove(user!.uid);
                                    });
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            ),
                          ],
                          if (EasyChat.instance.canSetUserAsModerator(room: widget.room, userUid: user.uid)) ...[
                            TextButton(
                              child: const Text("Add as a Moderator"),
                              onPressed: () {
                                EasyChat.instance.setUserAsModerator(
                                  room: widget.room,
                                  uid: user.uid,
                                  callback: () {
                                    setState(() {
                                      widget.room.moderators.add(user.uid);
                                    });
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            )
                          ],
                          if (EasyChat.instance.canRemoveUserAsModerator(room: widget.room, userUid: user.uid)) ...[
                            TextButton(
                              child: const Text("Remove as a Moderator"),
                              onPressed: () {
                                EasyChat.instance.removeUserAsModerator(
                                  room: widget.room,
                                  uid: user.uid,
                                  callback: () {
                                    setState(() {
                                      widget.room.moderators.remove(user.uid);
                                    });
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            )
                          ],
                          if (EasyChat.instance.canBlockUserFromGroup(room: widget.room, userUid: user.uid)) ...[
                            TextButton(
                              child: const Text('Block user from the group'),
                              onPressed: () {
                                EasyChat.instance.addToBlockedUsers(
                                  room: widget.room,
                                  uid: user.uid,
                                  callback: () {
                                    setState(() {
                                      widget.room.blockedUsers.add(user.uid);
                                    });
                                  },
                                );
                                debugPrint('Blocking this person');
                              },
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
