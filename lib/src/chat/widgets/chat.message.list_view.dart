import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:fireship/fireship.dart';
import 'package:fireship/ref.dart';
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

  final Widget Function(ChatMessageModel)? builder;
  final bool? primary;
  final Widget Function(BuildContext)? emptyBuilder;

  @override
  State<ChatMessageListView> createState() => _RChatMessageListState();
}

class _RChatMessageListState extends State<ChatMessageListView> {
  Widget? listView;

  String get roomId => widget.chat.room.id;
  ChatModel get chat => widget.chat;

  @override
  void initState() {
    super.initState();

    init();
  }

  init() async {
    final myJoinRef = Ref.join(myUid!, roomId);
    final join = ChatRoomModel.fromSnapshot(await myJoinRef.get());
    chat.resetNewMessage(join: join);
  }

  @override
  Widget build(BuildContext context) {
    final ref = ChatService.instance.messageRef(roomId: roomId);

    return FirebaseDatabaseQueryBuilder(
      // 페이지 사이즈(메시지를 가져오는 개수)를 100으로 해서, 자주 가져오지 않도록 한다. 그래서 flickering 을 줄인다.
      pageSize: 100,
      query: ref.orderByChild('order'),
      builder: (context, snapshot, _) {
        if (snapshot.isFetching) {
          // FirebaseDatabaseQueryBuilder 는 snapshot.isFetching 을 맨 처음 로딩할 때 딱 한번만 true 로 지정한다.
          // 단, 처음 로딩 할 때, FirestoreDatabaseQueryBuilder 가 여러번 번 호출 되어, snapshot.isFetching 로 여러번 true 로 지정된다.
          dog('snapshot.isFetching: ${snapshot.isFetching}');

          // 맨 처음 로딩을 할 때, loader 표시
          if (listView == null) {
            dog('listView is null');
            return const Center(child: CircularProgressIndicator());
          } else {
            dog('첫번째 로딩이 이미 완료되어, 기존에 그린 위젯을 그대로 사용.');
            // 만약, 이전에 (첫번째 100개 메시지를 보여주는 ListView) 위젯을 화면에 표시 했으면, 그 위젯을 다시 표시한다.
            // 즉, flickering 을 줄인다.
            return listView!;
          }
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
          final newMessage = ChatMessageModel.fromSnapshot(snapshot.docs.first);
          // newMessage 리셋
          chat.resetNewMessage(
            order: newMessage.createdAt != null ? -newMessage.createdAt! : null,
          );
        }

        // 메시지가 없는 경우,
        if (snapshot.docs.isEmpty) {
          listView = widget.emptyBuilder?.call(context) ??
              const Center(child: Text('There is no message, yet.'));
        } else {
          /// Reset the newMessage
          /// This is a good place to reset it since it is called when the user
          /// enters the room and every time it gets new message.
          listView = ListView.builder(
            padding: const EdgeInsets.all(0),
            reverse: true,
            primary: widget.primary,
            itemCount: snapshot.docs.length,
            itemBuilder: (context, index) {
              if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
                snapshot.fetchMore();
              }
              final message = ChatMessageModel.fromSnapshot(snapshot.docs[index]);

              /// 채팅방의 맨 마지막 메시지의 order 를 지정.
              chat.resetMessageOrder(order: message.order);

              return ChatBubble(
                message: message,
              );
            },
          );
        }
        return listView!;
      },
    );
  }
}
