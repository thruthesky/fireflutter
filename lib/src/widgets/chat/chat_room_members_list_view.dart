import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/models/chat_room_model.dart';
import 'package:flutter/material.dart';

class ChatRoomMembersListView extends StatefulWidget {
  const ChatRoomMembersListView({
    super.key,
    required this.room,
  });

  final ChatRoomModel room;

  @override
  State<ChatRoomMembersListView> createState() =>
      _ChatRoomMembersListViewState();
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
          future: UserService.instance.get(widget.room.users[index]),
          builder: (context, userSnapshot) {
            if (userSnapshot.data == null) return const SizedBox();
            final user = userSnapshot.data;
            return ListTile(
              title: Text(user?.displayName ?? ''),
              subtitle: RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: <TextSpan>[
                    TextSpan(
                        text: widget.room.master == user?.uid
                            ? 'Master '
                            : widget.room.moderators.contains(user?.uid)
                                ? 'Moderator '
                                : '',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (ChatService.instance
                        .isBlocked(room: widget.room, uid: user!.uid)) ...[
                      const TextSpan(text: 'Blocked'),
                    ],
                  ],
                ),
              ),
              leading: (user.photoUrl).isEmpty
                  ? null
                  : CircleAvatar(
                      backgroundImage: NetworkImage(user.photoUrl),
                    ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(user.displayName.isEmpty
                          ? user.uid
                          : user.displayName),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (ChatService.instance.canRemove(
                              room: widget.room, userUid: user.uid)) ...[
                            TextButton(
                              child: const Text('Remove from the Group'),
                              onPressed: () {
                                ChatService.instance.removeUserFromRoom(
                                  room: widget.room,
                                  uid: user.uid,
                                  callback: () {
                                    setState(() {
                                      widget.room.users.remove(user.uid);
                                    });
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            ),
                          ],
                          if (ChatService.instance.canSetUserAsModerator(
                              room: widget.room, userUid: user.uid)) ...[
                            TextButton(
                              child: const Text("Add as a Moderator"),
                              onPressed: () {
                                ChatService.instance.setUserAsModerator(
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
                          if (ChatService.instance.canRemoveUserAsModerator(
                              room: widget.room, userUid: user.uid)) ...[
                            TextButton(
                              child: const Text("Remove as a Moderator"),
                              onPressed: () {
                                ChatService.instance.removeUserAsModerator(
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
                          if (ChatService.instance.canBlockUserFromGroup(
                              room: widget.room, userUid: user.uid)) ...[
                            TextButton(
                              child: const Text('Block user from the group'),
                              onPressed: () {
                                ChatService.instance.addToBlockedUsers(
                                  room: widget.room,
                                  userUid: user.uid,
                                  callback: () {
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            ),
                          ],
                          if (ChatService.instance.canUnblockUserFromGroup(
                              room: widget.room, userUid: user.uid)) ...[
                            TextButton(
                              child: const Text('Unblock user from the group'),
                              onPressed: () {
                                ChatService.instance.removeToBlockedUsers(
                                  room: widget.room,
                                  uid: user.uid,
                                  callback: () {
                                    Navigator.pop(context);
                                  },
                                );
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
