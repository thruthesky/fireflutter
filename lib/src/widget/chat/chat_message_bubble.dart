import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/model/message.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:url_launcher/url_launcher.dart';

class ChatMessageBubble extends StatefulWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
  });

  final Message message;

  @override
  State<ChatMessageBubble> createState() => _ChatMessageBubbleState();
}

class _ChatMessageBubbleState extends State<ChatMessageBubble> {
  bool get isMyMessage => widget.message.senderUid == FirebaseAuth.instance.currentUser!.uid;
  late MainAxisAlignment bubbleMainAxisAlignment;
  late CrossAxisAlignment bubbleCrossAxisAlignment;
  Color? colorOfBubble;
  late BorderRadius borderRadiusOfBubble;
  Radius radiusOfCorners = const Radius.circular(16);

  @override
  Widget build(BuildContext context) {
    // TODO customizable UI
    // add new model for "bubble custom decoration"
    final borderRadiusOfBubbleOfOtherUser = BorderRadius.only(
      topRight: radiusOfCorners,
      bottomLeft: radiusOfCorners,
      bottomRight: radiusOfCorners,
    );
    final borderRadiusOfBubbleOfCurrentUser = BorderRadius.only(
      topLeft: radiusOfCorners,
      bottomLeft: radiusOfCorners,
      bottomRight: radiusOfCorners,
    );

    if (isMyMessage) {
      colorOfBubble = Theme.of(context).colorScheme.primaryContainer;
      bubbleMainAxisAlignment = MainAxisAlignment.end;
      bubbleCrossAxisAlignment = CrossAxisAlignment.end;
      borderRadiusOfBubble = borderRadiusOfBubbleOfCurrentUser;
    } else {
      colorOfBubble = Theme.of(context).colorScheme.tertiaryContainer;
      bubbleMainAxisAlignment = MainAxisAlignment.start;
      bubbleCrossAxisAlignment = CrossAxisAlignment.start;
      borderRadiusOfBubble = borderRadiusOfBubbleOfOtherUser;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: bubbleMainAxisAlignment,
      children: [
        if (!isMyMessage) ...[
          UserAvatar(
            uid: widget.message.senderUid,
            key: ValueKey(widget.message.id),
          ),
        ],
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: bubbleCrossAxisAlignment,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isMyMessage) ...[
                      UserDisplayName(uid: widget.message.senderUid),
                    ],
                  ],
                ),
                if (widget.message.text != null && widget.message.text!.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      color: colorOfBubble,
                      borderRadius: borderRadiusOfBubble,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.message.text!,
                            textAlign: isMyMessage ? TextAlign.right : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                if (widget.message.url != null && widget.message.url!.isNotEmpty)
                  CachedNetworkImage(imageUrl: widget.message.url!),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
