import 'package:fireflutter/fireflutter.dart';
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
/// [leave] 가 false 이면 메뉴에서 방나기를 보여주지 않는다. 예를 들면, 모든 사용자가 자동으로 접속하는 전체 채탱방에서는
/// 따로 방을 나갈 필요 없고, 나가도 다시 join 을 해야만 한다. 이와 같은 경우 사용을 하면 된다.
///
class ChatRoom extends StatefulWidget {
  const ChatRoom({
    super.key,
    this.uid,
    this.roomId,
    this.room,
    this.backButton = true,
    this.leave = true,
  });

  final String? uid;
  final String? roomId;
  final ChatRoomModel? room;
  final bool backButton;
  final bool leave;

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  ChatModel? _chat;
  ChatModel get chat => _chat!;

  /// 채팅방 정보가 로드되었는지 여부
  ///
  /// 채팅방 정보가 로드되었으면, 전체 화면을 다시 그리지 않고, 채팅 목록만 다시 그린다.
  /// 그래서, 채팅 화면 상단의 제목 부분이 깜빡거리지 않도록 한다.
  final loaded = ValueNotifier<bool>(false);

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

    /// 채팅방 정보 로드 완료
    loaded.value = true;

    ActionLog.chatJoin(chat.room.id);
    ActivityLog.chatJoin(chat.room.id);

    /// 방 정보 전체를 한번 읽고, 이후, 실시간 업데이트
    ///
    /// 참고, reload() 에 의해서 채팅방 정보를 한번 읽었을 수 있는데, 여기서 중복으로 한번 더 읽는다.
    /// 참고, setState() 를 하지 않는다. setState() 를 하게 되면, 화면이 깜빡거린다.
    ///
    /// 참고, 여기서 방 전체를 subscribe 하는데, 잘못된 것 같다. 필요한 필드만 subscribe 해야하는 것이 맞는 것 같다.
    chat.subscribeRoomUpdate(onUpdate: () => {});
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
              if (widget.backButton)
                const BackButton()
              else
                const SizedBox(
                  width: 16,
                ),

              /// 채팅방 제목
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    if (chat.room.isSingleChat) {
                      UserService.instance.showPublicProfileScreen(
                        context: context,
                        uid: chat.room.otherUserUid!,
                      );
                    }
                  },
                  child: Row(children: [
                    /// 사진
                    ///
                    /// 1:1 채팅은 chat-joins 에서 한번만 가져오고, 그룹 채팅은 chat-rooms 에서 가져온다.
                    /// 그룹 채팅은 관리자가 사진을 바꿀 때, 채팅 화면에 바로 적용되어야 한다.
                    chat.room.isSingleChat
                        ? Value.once(
                            path:
                                '${ChatJoinModel.join(myUid!, chat.room.id)}/${Field.photoUrl}',
                            builder: (v) => v == null
                                ? const SizedBox.shrink()
                                : Row(
                                    children: [
                                      Avatar(
                                        photoUrl: v,
                                        size: 40,
                                        radius: 18,
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                  ),
                          )
                        : Value(
                            path: ChatRoomModel.chatRoomIconUrl(chat.room
                                .id), // '${Path.join(myUid!, chat.room.id)}/${Field.photoUrl}',
                            builder: (v) => v == null
                                ? const SizedBox.shrink()
                                : Row(
                                    children: [
                                      Avatar(
                                        photoUrl: v,
                                        size: 40,
                                        radius: 18,
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                  ),
                          ),

                    /// 제목
                    ///
                    /// 1:1 채팅은 chat-joins 에서 한번만 가져오고, 그룹 채팅은 chat-rooms 에서 가져온다.
                    /// 그룹 채팅은 관리자가 채팅 이름을 바꿀 때, 채팅 화면에 바로 적용되어야 한다.
                    Expanded(
                      child: chat.room.isSingleChat
                          ? Value.once(
                              path:
                                  '${ChatJoinModel.join(myUid!, chat.room.id)}/name',
                              builder: (v) => Text(
                                v ?? '',
                                style: Theme.of(context).textTheme.titleLarge,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          : Value(
                              path: ChatRoomModel.chatRoomName(chat.room.id),
                              builder: (v) => Text(
                                v ?? '',
                                style: Theme.of(context).textTheme.titleLarge,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                    ),
                  ]),
                ),
              ),
              const SizedBox(width: 8),

              /// add notifications on and off
              IconButton(
                onPressed: () async {
                  await chat.room.toggleNotifications();
                },
                icon: Value(
                  path: ChatRoomModel.chatRoomUsersAt(chat.room.id, myUid!),
                  builder: (v) => v == true
                      ? const Icon(Icons.notifications_rounded)
                      : const Icon(Icons.notifications_outlined),
                ),
              ),
              if (chat.room.isGroupChat)
                ChatService.instance.customize.chatRoomInviteButton
                        ?.call(chat.room) ??
                    IconButton(
                      onPressed: () async {
                        ChatService.instance.showInviteScreen(
                            context: context, room: chat.room);
                      },
                      icon: const Icon(Icons.person_add_rounded),
                    ),

              ChatService.instance.customize.chatRoomMenu?.call(chat) ??
                  PopupMenuButton<String>(
                    itemBuilder: (_) => [
                      if (chat.room.isMaster || my!.isAdmin)
                        PopupMenuItem(
                          value: 'setting',
                          child: Text(T.setting.tr),
                        ),
                      const PopupMenuItem(
                        value: 'members',
                        child: Text(
                          // T.members.tr,
                          "Members",
                        ),
                      ),
                      if (chat.room.isSingleChat)
                        PopupMenuItem(
                          value: 'block',
                          child: MyDoc.field(
                            '${Field.blocks}/${chat.room.otherUserUid}',
                            builder: (v) =>
                                Text(v == null ? T.block : T.unblock.tr),
                          ),
                        ),
                      PopupMenuItem(value: 'report', child: Text(T.report.tr)),
                      if (widget.leave)
                        PopupMenuItem(value: 'leave', child: Text(T.leave.tr)),
                    ],
                    onSelected: (v) async {
                      if (v == 'setting') {
                        /// TODO 채팅방이 그룹 채팅이 아니라, 1:1 채팅인 경우, chat-joins 에서 설정을 해야 한다.
                        await ChatService.instance.showChatRoomSettings(
                          context: context,
                          roomId: chat.room.id,
                        );
                        setState(() {});
                      } else if (v == 'members') {
                        await ChatService.instance.showMembersScreen(
                          context: context,
                          room: chat.room,
                        );
                      } else if (v == 'block') {
                        /// 차단 & 해제
                        final re = await my?.block(chat.room.otherUserUid!);
                        if (context.mounted) {
                          toast(
                            context: context,
                            title: re == true ? T.blocked.tr : T.unblocked.tr,
                            message: re == true
                                ? T.blockedMessage.tr
                                : T.unblockedMessage.tr,
                          );
                        }
                      } else if (v == 'report') {
                        final re = await input(
                          context: context,
                          title: T.reportInputTitle.tr,
                          subtitle: T.reportInputMessage.tr,
                          hintText: T.reportInputHint.tr,
                        );
                        if (re == null || re == '') return;
                        await ReportService.instance
                            .report(chatRoomId: chat.room.id, reason: re);
                      } else if (v == 'leave') {
                        await chat.room.leave();
                        if (context.mounted) Navigator.of(context).pop();
                      }
                    },
                    tooltip: '채팅방 설정',
                    icon: const Icon(Icons.menu_rounded),
                  ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        /// 채팅 메시지
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: loaded,
            builder: (_, v, __) => v
                ? ChatMessageListView(
                    chat: chat,
                  )
                : const SizedBox.shrink(),
          ),
        ),

        /// 채팅 입력 박스
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
