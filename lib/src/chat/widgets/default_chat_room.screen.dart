import 'package:fireship/fireship.dart';
import 'package:fireship/ref.dart';
import 'package:flutter/material.dart';

/// 채팅방
///
/// 채팅 메시지를 보여주고, 새로운 채팅 메시지를 전송할 수 있도록 한다.
///
/// [uid] 가 들어오면, 해당 채팅방의 정보를 읽어서, 위젯을 빌드한다. 해당 채팅방이 없으면 생성한다.
///
/// [roomId] 가 들어오면, 해당 채팅방의 정보를 읽어서, 위젯을 빌드한다. 해당 채팅방이 없으면 에러를 발생시킨다. 그리고,
/// 채팅방에 join 한다.
///
/// [room] 이 들어오면, 해당 채팅방의 정보를 읽지 않고, 빠르게 위젯을 빌드한다. 그리고, join 한다.
///
///
///
class DefaultChatRoomScreen extends StatelessWidget {
  const DefaultChatRoomScreen({
    super.key,
    this.uid,
    this.roomId,
    this.room,
  });

  final String? uid;
  final String? roomId;
  final ChatRoomModel? room;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('채팅'),
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
            ],
            onSelected: (v) {
              if (v == 'edit') {
                /// TODO 채팅방이 그룹 채팅이 아니라, 1:1 채팅인 경우, chat-joins 에서 설정을 해야 한다.
                ChatService.instance.showChatRoomSettings(
                  context: context,
                  roomId: roomId ?? room?.id ?? '',
                );
              }
            },
            tooltip: '채팅방 설정',
            icon: const Icon(Icons.menu_rounded),
          ),
        ],
      ),
      body: ChatRoom(uid: uid, roomId: roomId, room: room),
    );
  }
}
