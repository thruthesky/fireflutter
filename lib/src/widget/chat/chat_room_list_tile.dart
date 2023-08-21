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
                : SizedBox(
                    width: avatarSize,
                    height: avatarSize,
                    child: Stack(
                      children: [
                        UserAvatar(
                          uid: room.users.last,
                          size: avatarSize / 1.6,
                          radius: 10,
                          borderWidth: 1,
                          borderColor: Colors.grey.shade300,
                        ),
                        if (room.lastMessage != null)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: UserAvatar(
                              uid: room.lastMessage?.senderUid,
                              size: avatarSize / 1.4,
                              radius: 10,
                              borderWidth: 1,
                              borderColor: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
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
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  room.lastMessageTime,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 2),
                NoOfNewMessageBadge(
                  room: room,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
