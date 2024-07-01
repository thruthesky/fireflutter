import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

/// 채팅방
///
/// 채팅 메시지를 보여주고, 새로운 채팅 메시지를 전송할 수 있도록 한다.
///
/// [uid] 가 들어오면, 1:1 채팅 방에 입장하는 것이다. 즉, uid 는 1:1 채팅에서
/// 다른 사용자의 uid 이다. 해당 채팅방의 정보를 읽어서, 위젯을 빌드한다. 해당 채팅방이 없으면 생성한다.
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
/// [displayAppBar] 가 false 이면 앱바를 표시하지 않는다. 예를 들면, 채팅 방을 탭바나 기타 다른 화면으로 임베드할 때 사용하면 된다.
///
/// [appBarBottomSpacing] 은 앱바 아래에 여백을 준다. 기본값은 8 이다.
///
class ChatRoomBody extends StatefulWidget {
  const ChatRoomBody({
    super.key,
    this.uid,
    this.roomId,
    this.room,
    this.backButton = true,
    this.leave = true,
    this.displayAppBar = true,
    this.appBarBottomSpacing = 8,
    this.emptyBuilder,
  });

  final String? uid;
  final String? roomId;
  final ChatRoom? room;
  final bool backButton;
  final bool leave;
  final bool displayAppBar;
  final double appBarBottomSpacing;
  final Widget Function(BuildContext)? emptyBuilder;

  @override
  State<ChatRoomBody> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoomBody> {
  ChatModel? _chat;
  ChatModel get chat => _chat!;

  /// [other] is the other user in 1:1 chat. It is null in group chat.
  /// If [other] is null on 1:1 chat, it means the user is deleted (not exists in the database).
  User? other;

  /// 채팅방 정보가 로드되었는지 여부
  ///
  /// 채팅방 정보가 로드되었으면, 전체 화면을 다시 그리지 않고, 채팅 목록만 다시 그린다.
  /// 그래서, 채팅 화면 상단의 제목 부분이 깜빡거리지 않도록 한다.
  final loaded = ValueNotifier<bool>(false);

  /// if there is an error while joining the chat room
  bool cannotJoin = false;
  bool get canChat => cannotJoin == false;

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
    } on FireFlutterException catch (e) {
      // See chat.md#Get ChatRoom on ChatRoomBody
      if (e.code == Code.chatRoomNotExists) {
        /// uid 또는 groupId 로 채팅방을 생성한다.
        final room = await ChatRoom.create(
          uid: widget.uid,
          roomId: widget.roomId,
        );
        chat.resetRoom(room: room);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 채팅방 초기화
  ///
  /// 이 함수가 호출되면, 채팅방 정보가 완전히 로드된다.
  init() async {
    /// ChatRoom 이 들어온 경우, 채팅방 정보를 읽지 않고, 그대로 쓴다.
    if (widget.room != null) {
      _chat = ChatModel(room: widget.room!);
    } else if (widget.uid != null) {
      // 1:1 채팅 방 - 방이 없으면 생성한다.
      _chat = ChatModel(room: ChatRoom.fromUid(widget.uid!));
      await reload();
    } else if (widget.roomId != null) {
      // 그룹 채팅 방 ID 가 들어온 경우 - 방이 없으면 생성한다.
      _chat = ChatModel(room: ChatRoom.fromRoomdId(widget.roomId!));
      await reload();
    } else {
      throw ArgumentError('uid, roomId, room 중 하나는 반드시 있어야 합니다.');
    }

    /// 탈퇴한 사용자인지 확인
    if (chat.room.isSingleChat) {
      other = await User.get(chat.room.otherUserUid!);
      setState(() {});
      if (other == null) {
        error(
          context: context,
          title: T.userNotFoundTitleOnSingleChat.tr,
          message: T.userNotFoundMessageOnSingleChat.tr,
        );
      }
    }

    if (chat.room.joined == false) {
      if (chat.room.hasPassword) {
        await joinWithPassword();
      } else {
        await join();
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

  /// Join to the chat room
  join() async {
    try {
      await chat.room.join();
    } on FireFlutterException catch (e) {
      setState(() => cannotJoin = true);
      if (e.code == Code.chatRoomNotVerified) {
        if (mounted) {
          await error(
            context: context,
            message: T.cannotEnterChatRoomWithoutVerification.tr,
          );
          if (mounted) {
            Navigator.of(context).pop();
          }
        }
      } else if (e.code == Code.chatRoomUserGenderNotAllowed) {
        if (mounted) {
          await error(
            context: context,
            message: e.message,
          );
          if (mounted) {
            Navigator.of(context).pop();
          }
        }
      } else {
        rethrow;
      }
    } catch (e) {
      setState(() => cannotJoin = true);
      rethrow;
    }
  }

  /// join chat room with password
  joinWithPassword() async {
    final password = await input(
      context: context,
      title: T.enterPassword.tr,
      hintText: T.password.tr,
    );
    if (password == null || password == '') {
      Navigator.of(context).pop();
      return;
    }
    try {
      await chat.room.joinWithPassword(password: password);
    } catch (e) {
      Navigator.of(context).pop();
      rethrow;
    }
  }

  @override
  void dispose() {
    /// 실시간 업데이트 subscription 해제
    _chat?.unsubscribeRoomUpdate();
    _chat?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 앱바 - 타이틀바
        if (widget.displayAppBar)
          SafeArea(
            bottom: false,
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
                          ? Value(
                              // path: '${ChatJoin.join(myUid!, chat.room.id)}/${Field.photoUrl}',
                              ref: ChatJoin.photoRef(chat.room.id),
                              builder: (v) => v == null
                                  ? const SizedBox.shrink()
                                  : Row(
                                      children: [
                                        Avatar(
                                          photoUrl:
                                              (v as String).orAnonymousUrl,
                                          size: 40,
                                          radius: 18,
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                    ),
                            )
                          : Value(
                              // path: ChatRoom.chatRoomIconUrl(chat.room .id), // '${Path.join(myUid!, chat.room.id)}/${Field.photoUrl}',
                              ref: ChatRoom.iconUrlRef(chat.room.id),
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
                            ? Value(
                                ref: ChatJoin.nameRef(chat.room.id),
                                builder: (v) => Text(
                                  v ?? '',
                                  style: Theme.of(context).textTheme.titleLarge,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            : Value(
                                ref: ChatRoom.nameRef(chat.room.id),
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
                if (cannotJoin == false) ...[
                  IconButton(
                    onPressed: () async {
                      await chat.room.toggleNotifications();
                    },
                    icon: Value(
                      ref: ChatRoom.usersAtRef(chat.room.id, myUid!),
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
                          if ((chat.room.isMaster || isAdmin) &&
                              chat.room.isGroupChat)
                            PopupMenuItem(
                              value: 'setting',
                              child: Text(T.setting.tr),
                            ),
                          if (chat.room.isGroupChat)
                            PopupMenuItem(
                              child: Text(T.share.tr),
                              value: 'share',
                            ),
                          PopupMenuItem(
                            value: 'members',
                            child: Text(
                              T.members.tr,
                            ),
                          ),
                          if (chat.room.isGroupChat &&
                              (isAdmin || chat.room.isMaster))
                            PopupMenuItem(
                              value: Field.blockedUsers,
                              child: Text(T.blockedUsers.tr),
                            ),
                          if (chat.room.isSingleChat)
                            PopupMenuItem(
                              value: 'block',
                              child: MyDoc(
                                builder: (my) => my == null
                                    ? const SizedBox.shrink()
                                    // : T.block.orBlocked(chat.room.otherUserUid!, T.unblock.tr),
                                    : Text(!my.blocked(chat.room.otherUserUid!)
                                        ? T.block.tr
                                        : T.unblock.tr),
                              ),
                            ),
                          PopupMenuItem(
                            value: 'report',
                            child: Text(T.report.tr),
                          ),
                          if (widget.leave &&
                              !chat.room.isMaster &&
                              chat.room.isGroupChat)
                            PopupMenuItem(
                                value: 'leave', child: Text(T.leave.tr)),
                        ],
                        onSelected: (v) async {
                          if (v == 'setting') {
                            /// 채팅방이 그룹 채팅이 아니라, 1:1 채팅인 경우, chat-joins 에서 설정을 해야 한다.
                            /// 이에 대한 내용은, ko/chat.md 를 한다.
                            await ChatService.instance.showChatRoomSettings(
                              context: context,
                              roomId: chat.room.id,
                            );
                            setState(() {});
                          } else if (v == 'share') {
                            await Share.shareUri(
                              LinkService.instance.generateChatRoomLink(
                                chat.room.id,
                              ),
                            );
                          } else if (v == 'members') {
                            await ChatService.instance.showUserListScreen(
                              context: context,
                              room: chat.room,
                            );
                          } else if (v == Field.blockedUsers) {
                            await ChatService.instance
                                .showBlockedUserListScreen(
                              context: context,
                              room: chat.room,
                            );
                          } else if (v == 'block') {
                            /// 1:1 채팅 방의 경우, 차단 & 해제
                            // final re =
                            await UserService.instance.block(
                                context: context,
                                otherUserUid: chat.room.otherUserUid!);
                          } else if (v == 'report') {
                            final re = await input(
                              context: context,
                              title: T.reportInputTitle.tr,
                              subtitle: T.reportInputMessage.tr,
                              hintText: T.reportInputHint.tr,
                            );
                            if (re == null || re == '') return;
                            await Report.create(
                              context: context,
                              chatRoomId: chat.room.id,
                              reason: re,
                            );
                          } else if (v == 'leave') {
                            await chat.room.leave();
                            if (context.mounted) Navigator.of(context).pop();
                          }
                        },
                        tooltip: T.chatRoomSettings.tr,
                        icon: const Icon(Icons.menu_rounded),
                      ),
                ]
              ],
            ),
          ),

        SizedBox(height: widget.appBarBottomSpacing),

        /// 채팅 메시지 목록 (Chat message list view)
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: loaded,
            builder: (_, v, __) => v
                ? ChatMessageListView(
                    chat: chat,
                    emptyBuilder: widget.emptyBuilder,
                  )
                : const SizedBox.shrink(),
          ),
        ),

        if (cannotJoin)
          Expanded(
            child: Center(
              child: Text(T.cannotJoinChatRoomError.tr),
            ),
          ),
        if (canChat)
          SafeArea(
            top: false,
            child: ChatMessageInputBox(
              chat: chat,
              other: other,
            ),
          ),
      ],
    );
  }
}
