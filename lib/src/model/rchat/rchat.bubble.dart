import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class RChatBubble extends StatelessWidget {
  const RChatBubble({
    super.key,
    required this.message,
  });

  final RChatMessageModel message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.mine) ...[
            const Spacer(),
            dateAndName(),
          ],
          // other avtar
          if (message.other)
            UserAvatar(
              uid: message.uid,
              radius: 13,
              onTap: () => UserService.instance.showPublicProfileScreen(
                context: context,
                uid: message.uid,
              ),
            ),

          const SizedBox(width: 8),
          // text
          if (message.text != null)
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: message.mine ? Colors.amber.shade200 : Colors.grey.shade200,
                borderRadius: borderRadius(),
              ),
              child: Text(message.text ?? '', style: const TextStyle(color: Colors.black)),
            ),
          // image
          if (message.url != null) cachedImage(context, message.url!),

          const SizedBox(width: 8),
          // my avtar
          if (message.mine)
            UserAvatar(
              user: my,
              radius: 13,
              onTap: () => UserService.instance.showPublicProfileScreen(
                context: context,
                uid: message.uid,
                user: my,
              ),
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

  enableOrDisableText(User user) {
    return user.isDisabled ? 'Enable' : 'Disable';
  }

  cachedImage(BuildContext context, String url) {
    return ClipRRect(
      borderRadius: borderRadius(),
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
        child: CachedNetworkImage(
          imageUrl: message.url!.thumbnail,
          fit: BoxFit.cover,
          // progressIndicatorBuilder: (context, url, downloadProgress) =>
          //     CircularProgressIndicator(value: downloadProgress.progress),
          placeholder: (context, url) => const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
          // if thumbnail is not available, show original image
          errorWidget: (context, url, error) => CachedNetworkImage(imageUrl: message.url!),
        ),
      ),
    );
  }
}
