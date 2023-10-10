import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// ChatRoomListTile
///
/// It is not the material [ListTile] since it does not support flexibilities.
class ChatRoomListTile extends StatefulWidget {
  const ChatRoomListTile({
    super.key,
    required this.room,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.onTap,
    this.avatarSize = 42,
  });
  final Room room;
  final EdgeInsets padding;
  final Function()? onTap;
  final double avatarSize;

  @override
  State<ChatRoomListTile> createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  User? otherUserData;

  @override
  Widget build(BuildContext context) {
    // print("---> $room");
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: Padding(
        padding: widget.padding,
        child: Row(
          children: [
            widget.room.isSingleChat
                ? UserAvatar(
                    uid: otherUserUid(widget.room.users),
                    size: widget.avatarSize,
                    radius: 16,
                    borderWidth: 0,
                    borderColor: Colors.grey.shade300,
                  )
                : SizedBox(
                    width: widget.avatarSize,
                    height: widget.avatarSize,
                    child: Stack(
                      children: [
                        UserAvatar(
                          uid: widget.room.users.last,
                          size: widget.avatarSize / 1.6,
                          radius: 10,
                          borderWidth: 1,
                          borderColor: Colors.grey.shade300,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: UserAvatar(
                            uid: widget.room.lastMessage?.uid,
                            size: widget.avatarSize / 1.4,
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
                    widget.room.isGroupChat
                        ? Text(widget.room.name, style: Theme.of(context).textTheme.bodyLarge)
                        : UserDoc(
                            uid: otherUserUid(widget.room.users),
                            builder: (_) {
                              otherUserData = _;
                              return Text(_.name, style: Theme.of(context).textTheme.bodyLarge);
                            },
                            onLoading: otherUserData != null
                                ? Text(otherUserData!.name, style: Theme.of(context).textTheme.bodyLarge)
                                : null,
                          ),
                    Text(
                      (widget.room.lastMessage?.text ?? '').replaceAll("\n", ' '),
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
                  widget.room.lastMessageTime,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 2),
                NoOfNewMessageBadge(
                  room: widget.room,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
