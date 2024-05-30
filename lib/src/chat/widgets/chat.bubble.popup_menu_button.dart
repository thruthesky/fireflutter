import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class ChatBubblePopupMenuButton extends StatelessWidget {
  const ChatBubblePopupMenuButton({
    super.key,
    required this.message,
    required this.room,
    required this.child,
    required this.onViewProfile,
    required this.onReply,
    required this.onDeleteMessage,
    required this.onBlock,
  });

  final ChatMessage message;
  final ChatRoom room;
  final Widget child;
  final void Function() onViewProfile;
  final void Function() onReply;
  final void Function() onDeleteMessage;
  final void Function() onBlock;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        isExpanded: true,
        customButton: child,
        openWithLongPress: true,
        items: [
          DropdownItem<String>(
            value: Code.reply,
            height: 40,
            child: Text(
              T.reply.tr,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
          if (message.mine || (room.isGroupChat && room.isMaster)) ...[
            DropdownItem<String>(
              value: Code.delete,
              child: Text(T.chatMessageDelete.tr),
            ),
          ],
          if (!message.mine)
            DropdownItem<String>(
              value: Code.viewProfile,
              height: 40,
              child: Text(
                T.viewProfile.tr,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          if (room.isGroupChat && room.isMaster)
            DropdownItem<String>(
              // We may need to use a different term or specific term for blocking in a group chat
              // in UX, the user may confuse that the block is the same for group chat and direct chat
              value: Code.block,
              child: Text(T.block.tr),
            ),
        ],
        // valueListenable: valueListenable,
        onChanged: (String? value) {
          // valueListenable.value = value;
          switch (value) {
            case Code.reply:
              onReply();
              break;
            case Code.delete:
              // await confirm(context: context, title: "test", message: "tset");
              // await message.delete();
              onDeleteMessage();
              break;
            case Code.viewProfile:
              onViewProfile();
              break;
            case Code.block:
              onBlock();
              break;
            default:
              break;
          }
        },
        style: Theme.of(context).textTheme.bodyMedium,
        buttonStyleData: const ButtonStyleData(
          overlayColor: WidgetStatePropertyAll(Colors.transparent),
        ),
        dropdownStyleData: const DropdownStyleData(
          width: 160,
        ),
      ),
    );
  }
}
