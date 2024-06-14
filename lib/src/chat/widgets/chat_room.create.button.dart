import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// ChatRoomCreateButton
///
/// [ChatRoomCreateButton] is a widget that creates a chat room.
///
/// [showAuthRequiredOption] is a boolean that will show an option
/// if verification of user is required before entering room.
class ChatRoomCreateButton extends StatelessWidget {
  const ChatRoomCreateButton({
    super.key,
    this.showAuthRequiredOption = false,
    this.icon,
  });

  final bool showAuthRequiredOption;

  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: icon ?? const Icon(Icons.add),
      onPressed: () async {
        final room = await ChatService.instance.showChatRoomCreate(
          context: context,
          showAuthRequiredOption: showAuthRequiredOption,
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
