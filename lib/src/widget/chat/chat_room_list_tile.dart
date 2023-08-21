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
  });
  final Room room;
  final EdgeInsets padding;
  final Function()? onTap;

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
                    size: 48,
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
                  children: [
                    ChatRoomListTileName(room: room),
                    ChatRoomNoOfNewMessageBadgesText(room: room),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '10:00',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 10),
                NoOfNewMessageBadge(room: room),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
