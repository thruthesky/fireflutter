import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

/// 채팅방 아바타(사진)
///
/// 1:1 채팅에서는 상대방 사진
/// 그룹 채팅에서는 그룹 사진 또는 그룹 사용자 사진.
class ChatRoomAvatar extends StatelessWidget {
  const ChatRoomAvatar({super.key, required this.room});

  final ChatRoomModel room;
  @override
  Widget build(BuildContext context) {
    return room.isSingleChat
        ? room.photoUrl == null
            ? const AnonymousAvatar()
            : Avatar(photoUrl: room.photoUrl!)
        : room.photoUrl == null
            ? const AnonymousAvatar(text: 'G')
            : Avatar(photoUrl: room.photoUrl!);
  }
}
