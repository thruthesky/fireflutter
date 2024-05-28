import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class DefaultChatRoomBlockedUserListScreen extends StatefulWidget {
  const DefaultChatRoomBlockedUserListScreen({
    super.key,
    required this.room,
  });

  final ChatRoom room;

  @override
  State<DefaultChatRoomBlockedUserListScreen> createState() =>
      _DefaultChatRoomBlockedUserListScreenState();
}

class _DefaultChatRoomBlockedUserListScreenState
    extends State<DefaultChatRoomBlockedUserListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blocked Users'),
      ),
      body: widget.room.blockedUsers.isEmpty
          ? Center(child: Text(T.chatEmptyBlockedUserList.tr))
          : ListView.separated(
              itemBuilder: (c, i) => ListTile(
                  leading: UserAvatar(
                    uid: widget.room.blockedUsers[i],
                  ),
                  title: UserDoc(
                    uid: widget.room.blockedUsers[i],
                    builder: (user) => Text(user.displayName),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await widget.room.unblock(widget.room.blockedUsers[i]);
                      setState(() {
                        widget.room.blockedUsers.removeAt(i);
                      });
                    },
                  )),
              separatorBuilder: (c, i) => const Divider(),
              itemCount: widget.room.blockedUsers.length,
            ),
    );
  }
}
