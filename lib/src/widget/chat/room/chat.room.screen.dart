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
      // ActivityService.instance.onChatRoomOpened(room!);
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
            setMessage: widget.setMessage,
          ),
        ],
      ),
    );
  }
}
