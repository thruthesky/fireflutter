import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// 채팅방 아바타(사진)
///
/// 1:1 채팅에서는 상대방 사진
/// 그룹 채팅에서는 그룹 사진 또는 그룹 사용자 사진.
class ChatRoomAvatar extends StatelessWidget {
  const ChatRoomAvatar({super.key, required this.room});

  final ChatRoom room;
  @override
  Widget build(BuildContext context) {
    return room.isSingleChat
        ? Avatar(
            photoUrl: (room.photoUrl ?? '').orAnonymousUrl,
            size: 52,
          )
        // 그룹 채팅방
        // 나의 채팅방 목록은 /chat-joins 에서 데이터를 가져오고
        // 그룹 채팅방 목록은 /chat-rooms 에서 데이터를 가져온다.
        : room.photoUrl == null
            ? room.iconUrl != null
                ? Avatar(photoUrl: room.iconUrl!)
                : const AnonymousAvatar(text: 'G')
            : Avatar(photoUrl: room.photoUrl!);
  }
}
