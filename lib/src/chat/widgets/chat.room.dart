import 'package:fireship/fireship.dart';
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
class ChatRoom extends StatefulWidget {
  const ChatRoom({
    super.key,
    this.uid,
    this.roomId,
    this.room,
  });

  final String? uid;
  final String? roomId;
  final ChatRoomModel? room;

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  ChatModel? _chat;
  ChatModel get chat => _chat!;

  @override
  void initState() {
    super.initState();

    if (notLoggedIn) {
      return;
    }

    init();
  }

  init() async {
    /// 채팅방 정보를 읽는다.
    if (widget.room != null) {
      _chat = ChatModel(room: widget.room!);
    } else if (widget.uid != null) {
      _chat = ChatModel(room: ChatRoomModel.fromUid(widget.uid!));
      await chat.room.reload();
    } else if (widget.roomId != null) {
      _chat = ChatModel(room: ChatRoomModel.fromRoomdId(widget.roomId!));
      await chat.room.reload();
    } else {
      throw ArgumentError('uid, roomId, room 중 하나는 반드시 있어야 합니다.');
    }

    if (chat.room.joined == false) {
      try {
        await chat.join();
      } on ErrorCode catch (e) {
        if (e.code == Code.chatRoomNotVerified) {
          rethrow;
        }
      } catch (e) {
        rethrow;
      }
    }

    /// 방 정보 전체를 한번 읽고, 이후, 실시간 업데이트
    chat.subscribeRoomUpdate(onUpdate: () => setState(() {}));
  }

  @override
  void dispose() {
    /// 실시간 업데이트 subscription 해제
    chat.unsubscribeRoomUpdate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// 로그인을 하지 않았으면, 로그인 요청 위젯 표시
    if (notLoggedIn) {
      return const DefaultLoginFirstScreen();
    }

    return Column(
      children: [
        Expanded(
          child: ChatMessageListView(
            chat: chat,
          ),
        ),
        SafeArea(
          top: false,
          child: ChatMessageInputBox(
            chat: chat,
          ),
        ),
      ],
    );
  }
}
