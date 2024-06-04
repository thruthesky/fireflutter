import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// This is a Popup Menu designed specifically for Chat Bubble.
class ChatBubblePopupMenuButton extends StatelessWidget {
  const ChatBubblePopupMenuButton({
    super.key,
    required this.message,
    required this.room,
    required this.child,
    this.onViewProfile,
    this.onBlockUser,
    this.onUnblockUser,
    this.onDeleteMessage,
    this.onReplyMessage,
  });

  final ChatMessage message;
  final ChatRoom room;
  final Widget child;
  final void Function(BuildContext context, String uid)? onViewProfile;
  final void Function(BuildContext context, String uid)? onBlockUser;
  final void Function(BuildContext context, String uid)? onUnblockUser;
  final void Function(BuildContext context, ChatMessage message)?
      onDeleteMessage;
  final void Function(BuildContext context, ChatMessage message)?
      onReplyMessage;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (details) {
        _showPopupMenu(context, details.globalPosition);
      },
      child: child,
    );
  }

  void _showPopupMenu(BuildContext context, Offset offset) async {
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(offset.dx, offset.dy, offset.dx, 0),
      // color: Theme.of(context).colorScheme.primaryContainer,
      items: [
        PopupMenuItem<String>(
          value: Code.reply,
          height: 40,
          child: Text(T.reply.tr),
        ),
        if ((message.mine || (room.isGroupChat && room.isMaster)) &&
            !message.deleted) ...[
          PopupMenuItem<String>(
            value: Code.delete,
            child: Text(T.chatMessageDelete.tr),
          ),
        ],
        if (!message.mine &&
            message.uid != null &&
            my?.hasBlocked(message.uid!) == false)
          PopupMenuItem<String>(
            value: Code.viewProfile,
            height: 40,
            child: Text(T.viewProfile.tr),
          ),
        if (room.isGroupChat && room.isMaster && !message.mine) ...[
          if (room.blockedUsers.contains(message.uid))
            PopupMenuItem<String>(
              value: Code.unblock,
              child: Text(T.unblock.tr),
            )
          else
            PopupMenuItem<String>(
              // We may need to use a different term or specific term for blocking in a group chat
              // in UX, the user may confuse that the block is the same for group chat and direct chat
              value: Code.block,
              child: Text(T.block.tr),
            ),
        ],
      ],
      // Review if we need shadow or remove
      // elevation: 0.0,
    ).then((value) {
      // Handle the selected value if needed
      if (value != null) {
        if (value == Code.reply) {
          (onReplyMessage ?? _onReplyMessage).call(context, message);
        } else if (value == Code.delete) {
          (onDeleteMessage ?? _onDeleteMessage).call(context, message);
        } else if (value == Code.viewProfile) {
          (onViewProfile ?? _onViewProfile).call(context, message.uid!);
        } else if (value == Code.block) {
          (onBlockUser ?? _onBlockUser).call(context, message.uid!);
        } else if (value == Code.unblock) {
          (onUnblockUser ?? _onUnblockUser).call(context, message.uid!);
        }
      }
    });
  }

  void _onViewProfile(BuildContext context, String uid) {
    UserService.instance.showPublicProfileScreen(
      context: context,
      uid: message.uid!,
    );
  }

  void _onReplyMessage(BuildContext context, ChatMessage message) {
    dog("@TODO reply message");
  }

  void _onDeleteMessage(BuildContext context, ChatMessage message) async {
    final deleteConfirmation = await confirm(
      context: context,
      title: T.deleteMessage.tr,
      message: T.deleteMessageConfirmation.tr,
    );
    if (deleteConfirmation ?? false) {
      await message.delete();
    }
  }

  void _onBlockUser(BuildContext context, String uid) async {
    final blockConfirmation = await confirm(
      context: context,
      title: T.blockUser.tr,
      message: T.blockUserChatConfirmation.tr,
    );
    if (blockConfirmation ?? false) {
      await room.block(message.uid!);
    }
  }

  void _onUnblockUser(BuildContext context, String uid) async {
    final unblockConfirmation = await confirm(
      context: context,
      title: T.unblockUser.tr,
      message: T.unblockUserChatConfirmation.tr,
    );
    if (unblockConfirmation ?? false) {
      await room.unblock(message.uid!);
    }
  }
}
