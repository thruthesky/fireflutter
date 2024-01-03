import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
  });

  final ChatMessageModel message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.mine) ...[
            const Spacer(),
            dateAndName(uid: myUid!),
          ],
          // other avtar
          if (message.other)
            UserAvatar(
              uid: message.uid!,
              size: 30,
              radius: 12,
              onTap: () => UserService.instance.showPublicProfile(
                context: context,
                uid: message.uid!,
              ),
            ),

          const SizedBox(width: 8),
          // text
          if (message.text != null)
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: message.mine ? Colors.amber.shade200 : Colors.grey.shade200,
                      borderRadius: borderRadius(),
                    ),
                    child: Text(
                      message.text ?? '',
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                  if (message.hasUrlPreview) ...[
                    const SizedBox(height: 8),
                    UrlPreview(
                      previewUrl: message.previewUrl!,
                      title: message.previewTitle,
                      description: message.previewDescription,
                      imageUrl: message.previewImageUrl,
                    ),
                  ],
                ],
              ),
            ),
          // image
          if (message.url != null) cachedImage(context, message.url!),

          const SizedBox(width: 8),
          // my avtar
          if (message.mine)
            UserAvatar(
              uid: myUid!,
              size: 30,
              radius: 12,
              onTap: () => UserService.instance.showPublicProfile(
                context: context,
                uid: myUid!,
              ),
            ),

          if (!message.mine) ...[
            dateAndName(uid: message.uid!),
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

  dateAndName({required String uid}) {
    return Column(
      crossAxisAlignment: message.mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          dateTimeShort(DateTime.fromMillisecondsSinceEpoch(message.createdAt ?? 0)),
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
        const SizedBox(width: 4),
        UserDoc(
          uid: uid,
          field: Def.displayName,
          builder: (data) => Text(
            data ?? 'NoName',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
        ),
      ],
    );
  }

  cachedImage(BuildContext context, String url) {
    return ClipRRect(
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
          // if thumbnail is not available, show original image
          errorWidget: (context, url, error) {
            return const Icon(Icons.error_outline, color: Colors.red);
          },
          errorListener: (value) => dog('Image not exist in storage: $value'),
        ),
      ),
    );
  }
}
