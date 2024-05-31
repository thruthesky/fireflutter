import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class ChatBubblePopupMenuButton extends StatefulWidget {
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
  State<ChatBubblePopupMenuButton> createState() =>
      _ChatBubblePopupMenuButtonState();
}

class _ChatBubblePopupMenuButtonState extends State<ChatBubblePopupMenuButton> {
  final valueListenable = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();

    valueListenable.addListener(() {
      print(valueListenable.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        isExpanded: true,
        customButton: widget.child,
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
          if (widget.message.mine ||
              (widget.room.isGroupChat && widget.room.isMaster)) ...[
            DropdownItem<String>(
              value: Code.delete,
              child: Text(T.chatMessageDelete.tr),
            ),
          ],
          if (!widget.message.mine)
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
          if (widget.room.isGroupChat &&
              widget.room.isMaster &&
              !widget.message.mine)
            DropdownItem<String>(
              // We may need to use a different term or specific term for blocking in a group chat
              // in UX, the user may confuse that the block is the same for group chat and direct chat
              value: Code.block,
              child: Text(T.block.tr),
            ),
        ],
        valueListenable: valueListenable,
        onChanged: (String? value) {
          // valueListenable.value = value;
          switch (value) {
            case Code.reply:
              widget.onReply();
              break;
            case Code.delete:
              // confirm(
              //   context: context,
              //   title: "Delete Message",
              //   message:
              //       "Are you sure you want to delete this message? This action cannot be undone.",
              // ).then((bool? deleteConfirmation) async {
              //   if (deleteConfirmation ?? false) {
              //     await widget.message.delete();
              //   }
              // });

              break;
            case Code.viewProfile:
              widget.onViewProfile();
              break;
            case Code.block:
              widget.onBlock();
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
