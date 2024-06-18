import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/chat/widgets/chat.read_more.dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    this.onCopy,
    this.onReadMore,
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
  final void Function(BuildContext context, ChatMessage message)? onCopy;
  final void Function(BuildContext context, ChatMessage message)? onReadMore;

  bool get isLongText =>
      message.text != null &&
      (message.text!.length > 360 ||
          '\n'.allMatches(message.text!).length > 10);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: _menuItems.isNotEmpty
          ? (details) {
              _showPopupMenu(context, details.globalPosition);
            }
          : null,
      child: child,
    );
  }

  List<PopupMenuItem<String>> get _menuItems => [
        if (onReplyMessage != null && !message.deleted)
          PopupMenuItem<String>(
            value: Code.reply,
            height: 40,
            child: Text(T.reply.tr),
          ),
        if (!message.deleted && isLongText)
          PopupMenuItem(
            value: Code.readMore,
            height: 40,
            child: Text(T.readMore.tr),
          ),
        if (!message.text.isNullOrEmpty && !message.deleted)
          PopupMenuItem(
            value: Code.copy,
            child: Text(T.copy.tr),
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
              value: Code.block,
              child: Text(T.block.tr),
            ),
        ],
      ];

  void _showPopupMenu(BuildContext context, Offset offset) async {
    final value = await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(offset.dx, offset.dy, offset.dx, 0),
      items: _menuItems,
    );

    if (value != null) {
      if (value == Code.readMore) {
        (onReadMore ?? _onReadMore).call(context, message);
      } else if (value == Code.reply) {
        (onReplyMessage ?? _onReplyMessage).call(context, message);
      } else if (value == Code.delete) {
        (onDeleteMessage ?? _onDeleteMessage).call(context, message);
      } else if (value == Code.viewProfile) {
        (onViewProfile ?? _onViewProfile).call(context, message.uid!);
      } else if (value == Code.block) {
        (onBlockUser ?? _onBlockUser).call(context, message.uid!);
      } else if (value == Code.unblock) {
        (onUnblockUser ?? _onUnblockUser).call(context, message.uid!);
      } else if (value == Code.copy) {
        (onCopy ?? _onCopy).call(context, message);
      }
    }
  }

  void _onViewProfile(BuildContext context, String uid) {
    UserService.instance.showPublicProfileScreen(
      context: context,
      uid: message.uid!,
    );
  }

  void _onReplyMessage(BuildContext context, ChatMessage message) {
    onReplyMessage!.call(context, message);
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

  void _onCopy(BuildContext context, ChatMessage message) async {
    await Clipboard.setData(ClipboardData(text: message.text!));
    toast(context: context, message: T.messageWasCopiedToClipboard.tr);
  }

  void _onReadMore(BuildContext context, ChatMessage message) {
    showDialog(
      context: context,
      builder: (context) {
        return ChatReadMoreDialog(
          message: message,
        );
      },
    );
  }
}
