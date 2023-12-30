import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class DefaultChatRoomScreen extends StatefulWidget {
  const DefaultChatRoomScreen({
    super.key,
    this.uid,
    this.roomId,
  });

  final String? uid;
  final String? roomId;

  @override
  State<DefaultChatRoomScreen> createState() => _DefaultChatRoomScreenState();
}

class _DefaultChatRoomScreenState extends State<DefaultChatRoomScreen> {
  StreamSubscription<DatabaseEvent>? subscription;
  late ChatModel chat;

  @override
  void initState() {
    super.initState();

    if (notLoggedIn) {
      return;
    }

    chat = ChatModel(
      room: widget.uid != null
          ? ChatRoomModel.fromUid(widget.uid!)
          : ChatRoomModel.fromRoomdId(widget.roomId!),
    );

    /// 현재 채팅방 listen
    subscription = chat.room.ref.onValue.listen((event) async {
      if (event.snapshot.exists) {
        // 채팅방이 존재하면, 채팅방 정보를 가져오고, 재 설정
        final room = ChatRoomModel.fromSnapshot(event.snapshot);
        chat.resetRoom(room: room);
        // 그리고 채팅방에 join (이미 join 되어 있으면, 아무것도 하지 않는다.)
        chat.join();
      } else {
        // 채팅방이 존재하지 않으면, 채팅방을 생성하고, 재 설정
        final room = await ChatRoomModel.create(uid: widget.uid);
        chat.resetRoom(room: room);
      }

      setState(() {});
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return loggedIn
        ? Scaffold(
            appBar: AppBar(
              title: const Text('채팅'),
              actions: const [],
            ),
            body: Column(
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
            ),
          )
        : const DefaultLoginFirstScreen();
  }
}
