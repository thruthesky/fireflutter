import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/widget/user/user.text.dart';
import 'package:flutter/material.dart';

class RChatBubble extends StatelessWidget {
  const RChatBubble({super.key, required this.message});

  final RChatMessageModel message;

  @override
  Widget build(BuildContext context) {
    print('--> RChatBubble.build() message: ${message.toJson()}');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.mine) ...[
            const Spacer(),
            dateAndName(),
          ],
          if (!message.mine)
            UserAvatar(
              uid: message.uid,
              radius: 13,
            ),
          const SizedBox(width: 8),
          if (message.text != null)
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: message.mine ? Colors.amber.shade200 : Colors.grey.shade200,
                borderRadius: borderRadius(),
              ),
              child: Text(message.text ?? ''),
            ),
          if (message.url != null)
            ClipRRect(
              borderRadius: borderRadius(),
              child: Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
                child: CachedNetworkImage(
                  imageUrl: message.url!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
          const SizedBox(width: 8),
          if (message.mine)
            UserAvatar(
              user: my,
              radius: 13,
            ),
          if (!message.mine) ...[
            dateAndName(),
            const Spacer(),
          ],
        ],
      ),
    );
  }

  borderRadius() {
    return BorderRadius.only(
      topLeft: Radius.circular(message.mine ? 16 : 0),
      topRight: Radius.circular(message.mine ? 0 : 16),
      bottomLeft: const Radius.circular(16),
      bottomRight: const Radius.circular(16),
    );
  }

  dateAndName() {
    return Column(
      crossAxisAlignment: message.mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          dateTimeShort(DateTime.fromMillisecondsSinceEpoch(message.createdAt ?? 0)),
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
        const SizedBox(width: 4),
        UserText(
          user: message.mine ? my : null,
          uid: message.mine ? null : message.uid,
          field: 'name',
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
