import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class ChatRoomListTile extends StatelessWidget {
  const ChatRoomListTile({super.key, required this.room});

  final ChatRoomModel room;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ChatRoomAvatar(
        room: room,
      ),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              room.name ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (room.isGroupChat) ...[
            const SizedBox(width: 4),
            Text(
              '${room.noOfUsers ?? ''}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ],
      ),
      subtitle: Text(
        subtitle(context, room),
        style: Theme.of(context).textTheme.labelSmall!.copyWith(fontSize: 11),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      onTap: () {
        dog('room.id: ${room.id}');
        dog('room.id: ${room.key}');
        ChatService.instance.showChatRoom(context: context, roomId: room.id);
        // context.push(AllRoomScreen.routeName, extra: {'roomId': room.id});
      },
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            dateTimeShort(DateTime.fromMillisecondsSinceEpoch(room.updatedAt!)),
            style:
                Theme.of(context).textTheme.labelSmall!.copyWith(fontSize: 10),
          ),
          ChatNewMessage(room: room),
        ],
      ),
    );
  }

  String? text(ChatRoomModel room) {
    if (room.text != null) return room.text!.replaceAll('\n', ' ');
    if (room.url != null) return '사진을 보내셨습니다.';
    return null;
  }

  String subtitle(BuildContext context, ChatRoomModel room) {
    if (room.isSingleChat) {
      if (my?.isBlocked(room.otherUserUid!) == true) {
        return T.thisIsBlockedUser.tr;
      }
    }

    return text(room) ?? '';
  }
}
