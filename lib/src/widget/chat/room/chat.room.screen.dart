import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({
    super.key,
    this.room,
    this.user,
    this.setMessage,
  });

  final Room? room;
  final User? user;
  final String? setMessage;

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
        if (mounted) setState(() {});
      }
      ChatService.instance.resetNoOfNewMessage(room: room!);
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
                : widget.room?.isGroupChat == true
                    ? ChatRoomMessageListView(roomId: roomId)
                    : UserBlocked(
                        // Review: Check if this is necessary since the login user who blocked this user cannot open chat chat.
                        // This might be necessary if we have other ways to access the chat room.
                        // Also, for now, we are not blocking push notification from blocked users.
                        // So, if the user tapped on the notification, the chat room may appear.
                        // However, logically, there should be no push notification from the start.
                        // Moreover, there might be other ways to access the room, it might be better
                        // if we have this especially when we don't have integration testing yet.
                        otherUid: widget.user?.uid ?? widget.room!.otherUserUid,
                        notBlockedBuilder: (context) {
                          return ChatRoomMessageListView(roomId: roomId);
                        },
                        blockedBuilder: (context) {
                          return const Center(child: Text('You cannot chat with this user.'));
                        },
                      ),
          ),
          ChatRoomMessageBox(
            room: room,
          ),
        ],
      ),
    );
  }
}
