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
          Text(
            room.name ?? '',
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
      subtitle: subtitle(context, room),
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
            style: Theme.of(context).textTheme.labelSmall!.copyWith(fontSize: 10),
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

  Widget? subtitle(BuildContext context, ChatRoomModel room) {
    final text = this.text(room);
    if (text == null) return null;

    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall!.copyWith(fontSize: 11),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }
}
