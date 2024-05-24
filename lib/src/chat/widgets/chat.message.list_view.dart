import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// Chat Message List
///
/// Display chat message
///
/// [chat.room] 에는 완전한 채팅방 정보 및 옵션(속성 값)이 들어가 있다. 이 옵션에 따라 적절한 처리를 하면 된다.
///
class ChatMessageListView extends StatefulWidget {
  const ChatMessageListView({
    super.key,
    required this.chat,
    this.builder,
    this.primary,
    this.emptyBuilder,
  });

  final ChatModel chat;

  final Widget Function(ChatMessage)? builder;
  final bool? primary;
  final Widget Function(BuildContext)? emptyBuilder;

  @override
  State<ChatMessageListView> createState() => _ChatMessageListViewState();
}

class _ChatMessageListViewState extends State<ChatMessageListView> {
  String get roomId => widget.chat.room.id;
  ChatModel get chat => widget.chat;

  /// 채팅방의 상대방 uid.
  ///
  /// 주의: 채팅방이 싱글 채팅이 아닌 경우, null operator used on a null value 에러가 발생할 수 있다.
  String get otherUserUid => chat.room.otherUserUid!;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    final myJoinRef = ChatJoin.joinRef(myUid!, roomId);
    final join = ChatRoom.fromSnapshot(await myJoinRef.get());
    chat.resetNewMessage(join: join);
  }

  @override
  Widget build(BuildContext context) {
    final ref = ChatService.instance.messageRef(roomId: roomId);

    if (chat.room.isSingleChat && iHave.blocked(otherUserUid)) {
      return Center(child: Text(T.blockedChatMessage.tr));
    }

    return FirebaseDatabaseQueryBuilder(
      // 페이지 사이즈(메시지를 가져오는 개수)를 100으로 해서, 자주 가져오지 않도록 한다. 그래서 flickering 을 줄인다.
      pageSize: 100,
      query: ref.orderByChild('order'),
      builder: (context, snapshot, _) {
        if (snapshot.isFetching) {
          // FirebaseDatabaseQueryBuilder 는 snapshot.isFetching 을 맨 처음 로딩할 때 딱 한번만 true 로 지정한다.
          // 단, 처음 로딩 할 때, FirestoreDatabaseQueryBuilder 가 여러번 번 호출 되어, snapshot.isFetching 로 여러번 true 로 지정된다.
          dog('ChatMessageListView -> FirebaseDatabaseQueryBuilder -> snapshot.isFetching: ${snapshot.isFetching}');

          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          dog(snapshot.error.toString());
          if (snapshot.error.toString().contains('permission-denied')) {
            return const Center(child: Text('권한이 없습니다.'));
          } else {
            return Text('Something went wrong! ${snapshot.error}');
          }
        }

        // 새로운 채팅이 들어오면(전달되어져 오면), 채팅방의 새 메시지 갯수를 0 으로 초기화 시킨다.
        if (chat.isLoadingNewMessage(roomId, snapshot)) {
          final newMessage = ChatMessage.fromSnapshot(snapshot.docs.first);
          // newMessage 리셋
          chat.resetNewMessage(
            order: newMessage.createdAt != null ? -newMessage.createdAt! : null,
          );
        }

        // 메시지가 없는 경우,
        if (snapshot.docs.isEmpty) {
          return widget.emptyBuilder?.call(context) ??
              Center(
                  child: Text(
                T.chatRoomNoMessageYet.tr,
                textAlign: TextAlign.center,
              ));
        } else {
          /// Reset the newMessage
          /// This is a good place to reset it since it is called when the user
          /// enters the room and every time it gets new message.
          return ListView.builder(
            padding: const EdgeInsets.all(0),
            reverse: true,
            primary: widget.primary,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            itemCount: snapshot.docs.length,
            itemBuilder: (context, index) {
              if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
                snapshot.fetchMore();
              }
              final message = ChatMessage.fromSnapshot(snapshot.docs[index]);

              /// 채팅방의 맨 마지막 메시지의 order 를 지정.
              chat.resetMessageOrder(order: message.order);

              /// 채팅방 메세지 버블
              final bubble =
                  ChatService.instance.customize.chatBubbleBuilder?.call(
                        context: context,
                        message: message,
                        onChange: () => setState(() {}),
                      ) ??
                      ChatBubble(
                        message: message,
                        onChange: () => setState(() {}),
                      );

              /// unfocus 를 상단에서 하면, 채팅 메시지 목록을 다시 불러와야하며, 이 때 로더가 화면에 보여질 수 있다.
              /// 그래서, 여기에서 unfocus 를 하면, 채팅메시지 목록을 다시 불러오지 않는다.
              if (isAdmin == false && chat.room.isMaster == false) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: bubble,
                );
              }
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  FocusScope.of(context).unfocus();
                  showBottomSheet(
                      context: context,
                      builder: (context) {
                        return ChatRoomMessageMenuBottomSheet(
                          chat: chat,
                          message: message,
                        );
                      });
                },
                child: IgnorePointer(child: bubble),
              );
            },
          );
        }
      },
    );
  }
}
