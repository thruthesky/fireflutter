import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// ChatRoomListTile
///
/// It is not the material [ListTile] since it does not support flexibilities.
class ChatRoomListTile extends StatelessWidget {
  const ChatRoomListTile({
    super.key,
    required this.room,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.onTap,
    this.avatarSize = 40,
  });
  final Room room;
  final EdgeInsets padding;
  final Function()? onTap;
  final double avatarSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: Row(
          children: [
            room.isSingleChat
                ? UserAvatar(
                    uid: otherUserUid(room.users),
                    size: avatarSize,
                    radius: 10,
                    borderWidth: 1,
                    borderColor: Colors.grey.shade300,
                  )
                : const Icon(Icons.group),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    room.isGroupChat
                        ? Text(room.name, style: Theme.of(context).textTheme.bodyLarge)
                        : UserDoc(
                            builder: (_) => Text(_.name, style: Theme.of(context).textTheme.bodyLarge),
                            uid: otherUserUid(room.users)),
                    Text(
                      (room.lastMessage?.text ?? '').replaceAll("\n", ' '),
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            NoOfNewMessageBadge(
              room: room,
              builder: (no) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    room.lastMessageTime,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 2),
                  no == 0
                      ? const SizedBox.shrink()
                      : Badge(
                          backgroundColor: Colors.orange.shade900,
                          label: Text('$no'),
                        )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
