import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// Chat Room User List View
///
/// Displays the list of users in the chat room.
///
/// It can be used in any where for any cases as long as the chat room model is given.
///
/// TODO support all the listview option, so the parent widget can use it as a normal listview.
class ChatRoomUserListView extends StatefulWidget {
  const ChatRoomUserListView({
    super.key,
    required this.room,
  });

  final Room room;

  @override
  State<ChatRoomUserListView> createState() => _ChatRoomUserListViewState();
}

class _ChatRoomUserListViewState extends State<ChatRoomUserListView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.room.users.length,
      itemBuilder: (context, index) {
        return FutureBuilder(
          future: UserService.instance.get(widget.room.users[index]),
          builder: (context, userSnapshot) {
            // On user document is not found
            if (userSnapshot.data == null) return const SizedBox();

            //
            final User user = userSnapshot.data!;

            //
            return ChatRoomUserListTile(
              room: widget.room,
              user: user,
            );
          },
        );
      },
    );
  }
}
