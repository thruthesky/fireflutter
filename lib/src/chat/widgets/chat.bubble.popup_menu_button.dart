import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/chat/widgets/chat.read_more.dialog.dart';
import 'package:flutter/material.dart';

class ChatBubblePopupMenuButton extends StatelessWidget {
  const ChatBubblePopupMenuButton({
    super.key,
    required this.message,
    required this.room,
    required this.child,
    required this.onViewProfile,
  });

  final ChatMessage message;
  final ChatRoom room;
  final Widget child;
  final void Function() onViewProfile;

  @override
  Widget build(BuildContext context) {
    /// 관리자이거나 방장이면, 팝업 메뉴 버튼을 리턴
    return PopupMenuButton(
      position: PopupMenuPosition.under,
      onOpened: () => FocusScope.of(context).focusedChild?.unfocus(),
      offset: Offset(
        message.mine ? MediaQuery.of(context).size.width : 0,
        0,
      ),
      itemBuilder: (context) => <PopupMenuEntry<String>>[
        PopupMenuItem(
          value: Code.readMore,
          child: Text(T.readMore.tr),
        ),
        PopupMenuItem(
          value: Code.reply,
          child: Text(T.reply.tr),
        ),
        const PopupMenuItem(
          value: Code.edit,
          // TODO T.edit.tr
          child: Text("Edit"),
        ),
        if (message.mine || (room.isGroupChat && room.isMaster)) ...[
          PopupMenuItem(
            value: Code.delete,
            child: Text(T.chatMessageDelete.tr),
          ),
        ],
        if (!message.mine) ...[
          PopupMenuItem(
            value: Code.viewProfile,
            child: Text(T.viewProfile.tr),
          ),
          if (room.isGroupChat)
            PopupMenuItem(
              // We may need to use a different term or specific term for blocking in a group chat
              // in UX, the user may confuse that the block is the same for group chat and direct chat
              value: Code.block,
              child: Text(T.block.tr),
            ),
        ],
      ],
      onSelected: (v) async {
        switch (v) {
          case Code.readMore:
            // show ReadMoreDialog
            await showDialog(
              context: context,
              builder: (context) {
                return ChatReadMoreDialog(
                  message: message,
                );
              },
            );
            break;
          case Code.reply:
            print("onReply?.call(message);");
            break;
          case Code.edit:
            print("onEdit?.call(message);");
            break;
          case Code.delete:
            await message.delete();
            break;
          case Code.viewProfile:
            onViewProfile();
            break;
          case Code.block:
            await room.block(message.uid!);
            break;
          default:
            break;
        }
      },
      child: child,
    );
  }
}
