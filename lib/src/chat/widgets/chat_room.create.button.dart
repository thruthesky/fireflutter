import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// ChatRoomCreateButton
///
/// [ChatRoomCreateButton] is a widget that creates a chat room.
///
/// [authRequired] is a boolean value that determines whether the user must be authenticated to join the chat room.
class ChatRoomCreateButton extends StatelessWidget {
  const ChatRoomCreateButton({
    super.key,
    this.authRequired = false,
  });

  final bool authRequired;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.add),
      onPressed: () async {
        final room = await ChatService.instance.showChatRoomCreate(
          context: context,
          authRequired: authRequired,
        );
        if (room == null) return;

        await ChatService.instance.showChatRoomScreen(
          context: context,
          room: room,
        );
      },
    );
  }
}
