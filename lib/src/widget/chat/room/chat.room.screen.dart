import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({
    super.key,
    this.room,
    this.user,
  });

  final Room? room;
  final User? user;

  @override
  State<ChatRoomScreen> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoomScreen> {
  Room? room;
  @override
  void initState() {
    super.initState();

    (() async {
      if (widget.room != null) {
        room = widget.room;
        // Join the group chat, if the user didn't join yet.
        if (room!.open && room!.users.contains(myUid) == false) {
          await room!.join();
        }
      } else {
        // If this take time, provide the room model without await. It may be passed from the previous of previous screen, Or it can be saved in a state.
        room = await ChatService.instance.getOrCreateSingleChatRoom(widget.user!.uid);
        setState(() {});
      }

      ChatService.instance.resetNoOfNewMessage(room: room!);

      // Why do we need to clear last message when somebody enters the chat room?
      // ChatService.instance.clearLastMessage();
    })();
  }

  String get roomId => widget.user != null ? ChatService.instance.getSingleChatRoomId(widget.user!.uid) : room!.roomId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChatService.instance.customize.chatRoomAppBarBuilder?.call(room: room, user: widget.user) ??
          ChatRoomAppBar(room: room, user: widget.user),
      body: Column(
        children: [
          Expanded(
            child: room == null
                ? const Center(child: CircularProgressIndicator.adaptive())
                : ChatRoomMessageListView(
                    roomId: roomId,
                  ),
          ),
          if (room != null) ChatRoomMessageBox(room: room!),
        ],
      ),
    );
  }
}
