import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/chat/widgets/room/chat.room.photoFrame.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// # ChatBubble Widget
/// Used for displaying a bubble in chat room
class ChatBubbleWidget extends StatelessWidget {
  const ChatBubbleWidget({
    super.key,
    required this.message,
    required this.nameInBubble,
    required this.isMyMessage,
    required this.photoUrl,
  });

  final ChatMessageModel message;
  final String nameInBubble;
  final bool isMyMessage;
  final String photoUrl;

  @override
  Widget build(BuildContext context) {
    late final MainAxisAlignment bubbleAlignment;
    late final Color colorOfBubble;
    late final BorderRadius borderRadiusOfBubble;
    const radiusOfCorners = Radius.circular(16);
    const borderRadiusOfBubbleOfOtherUser = BorderRadius.only(
      topRight: radiusOfCorners,
      bottomLeft: radiusOfCorners,
      bottomRight: radiusOfCorners,
    );
    const borderRadiusOfBubbleOfCurrentUser = BorderRadius.only(
      topLeft: radiusOfCorners,
      bottomLeft: radiusOfCorners,
      bottomRight: radiusOfCorners,
    );
    // To set the bubble details
    if (isMyMessage) {
      colorOfBubble = Theme.of(context).colorScheme.primary;
      bubbleAlignment = MainAxisAlignment.end;
      borderRadiusOfBubble = borderRadiusOfBubbleOfCurrentUser;
    } else {
      colorOfBubble = Theme.of(context).colorScheme.tertiary;
      bubbleAlignment = MainAxisAlignment.start;
      borderRadiusOfBubble = borderRadiusOfBubbleOfOtherUser;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0, horizontal: 14.0),
      child: Row(
        mainAxisAlignment: bubbleAlignment,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMyMessage) ...[
            if (photoUrl.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(photoUrl),
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ]
          ],
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                color: colorOfBubble,
                borderRadius: borderRadiusOfBubble,
              ),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nameInBubble,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                    Text(
                      'at ${DateFormat.yMMMd().add_jm().format(message.createdAt)}',
                      style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                    ),
                    if (message.photoUrl.isNotEmpty) ...[
                      PhotoFrame(
                        imagePath: message.photoUrl.toString(),
                      ),
                    ],
                    if (message.text.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(message.text),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ),
          if (isMyMessage) ...[
            if (photoUrl.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(photoUrl),
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ]
          ],
        ],
      ),
    );
  }
}
