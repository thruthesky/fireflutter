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

  bool loaded = false;

  @override
  void initState() {
    super.initState();

    if (notLoggedIn) {
      return;
    }

    init();
  }

  /// 채팅방 정보 읽기
  ///
  /// 1:1 채팅 또는 Group 채팅방이 존재하지 않으면 그냥 생성을 해 버린다.
  Future<void> reload() async {
    try {
      await chat.room.reload();
    } on Issue catch (e) {
      // See chat.md#Get ChatRoomModel on ChatRoom
      if (e.code == Code.chatRoomNotExists) {
        /// uid 또는 groupId 로 채팅방을 생성한다.
        final room = await ChatRoomModel.create(
          uid: widget.uid,
          roomId: widget.roomId,
        );
        chat.resetRoom(room: room);
      }
    } catch (e) {
      rethrow;
    }
  }

  init() async {
    /// ChatRoomModel 이 들어온 경우, 채팅방 정보를 읽지 않고, 그대로 쓴다.
    if (widget.room != null) {
      _chat = ChatModel(room: widget.room!);
    } else if (widget.uid != null) {
      // 1:1 채팅 방 - 방이 없으면 생성한다.
      _chat = ChatModel(room: ChatRoomModel.fromUid(widget.uid!));
      await reload();
    } else if (widget.roomId != null) {
      // 그룹 채팅 방 - 방이 없으면 생성한다.
      _chat = ChatModel(room: ChatRoomModel.fromRoomdId(widget.roomId!));
      await reload();
    } else {
      throw ArgumentError('uid, roomId, room 중 하나는 반드시 있어야 합니다.');
    }

    if (chat.room.joined == false) {
      try {
        await chat.join();
      } on Issue catch (e) {
        if (e.code == Code.chatRoomNotVerified) {
          if (mounted) {
            error(context: context, message: '본인 인증을 하지 않아 채팅방에 입장할 수 없습니다.');
          }
          rethrow;
        }
      } catch (e) {
        rethrow;
      }
    }

    setState(() {
      loaded = true;
    });

    /// 방 정보 전체를 한번 읽고, 이후, 실시간 업데이트
    ///
    /// 참고, reload() 에 의해서 채팅방 정보를 한번 읽었을 수 있는데, 여기서 중복으로 한번 더 읽는다.
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
        // 앱바 - 타이틀바
        SafeArea(
          child: Row(
            children: [
              const BackButton(),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (chat.room.isSingleChat) {
                    UserService.instance.showPublicProfile(
                      context: context,
                      uid: chat.room.otherUserUid!,
                    );
                  }
                },
                child: Database.once(
                  path: '${Path.join(myUid!, chat.room.id)}/name',
                  builder: (v, p) => Text(
                    v ?? '',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'setting', child: Text(T.setting.tr)),
                  PopupMenuItem(value: 'block', child: Text(T.block.tr)),
                  PopupMenuItem(value: 'report', child: Text(T.report.tr)),
                  PopupMenuItem(value: 'leave', child: Text(T.leave.tr)),
                ],
                onSelected: (v) {
                  if (v == 'setting') {
                    /// TODO 채팅방이 그룹 채팅이 아니라, 1:1 채팅인 경우, chat-joins 에서 설정을 해야 한다.
                    ChatService.instance.showChatRoomSettings(
                      context: context,
                      roomId: chat.room.id,
                    );
                  }
                },
                tooltip: '채팅방 설정',
                icon: const Icon(Icons.menu_rounded),
              ),
            ],
          ),
        ),
        Expanded(
          child: loaded
              ? ChatMessageListView(
                  chat: chat,
                )
              : const SizedBox.shrink(),
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
