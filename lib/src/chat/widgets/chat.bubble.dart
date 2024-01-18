import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

/// Chat bubble
///
/// Displays a chat message.
///
/// If [uid] is blocked, show a message that the user is blocked.
///
/// If the chat bubble needs to be rebuild when something chagned, [onChange]
/// will be called. One example is when the login user open's other's profile
/// and block/unblock.
class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    this.onChange,
  });

  final ChatMessageModel message;
  final Function? onChange;

  @override
  Widget build(BuildContext context) {
    if (my!.isBlocked(message.uid!)) {
      return blockedUserMessage(context);
    }

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
              key: ValueKey(message.key),
              uid: message.uid!,
              cacheId: 'chatRoom',
              size: 30,
              radius: 12,
              onTap: () => UserService.instance
                  .showPublicProfile(
                    context: context,
                    uid: message.uid!,
                  )
                  .then(
                    (value) => onChange?.call(),
                  ),
            ),

          const SizedBox(width: 8),
          // text
          if (message.text != null)
            Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.6),
              child: Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: message.mine
                          ? Colors.amber.shade200
                          : Colors.grey.shade200,
                      borderRadius: borderRadius(),
                    ),
                    child: LinkifyText(
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
              cacheId: 'chatRoom',
              size: 30,
              radius: 12,
              onTap: () => UserService.instance
                  .showPublicProfile(
                    context: context,
                    uid: myUid!,
                  )
                  .then((value) => onChange?.call()),
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
      crossAxisAlignment:
          message.mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        DateTimeShort(stamp: message.createdAt ?? 0),
        const SizedBox(width: 4),
        UserDisplayName(uid: uid),
      ],
    );
  }

  cachedImage(BuildContext context, String url) {
    return ClipRRect(
      borderRadius: borderRadius(),
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
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

  blockedUserMessage(context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => UserService.instance
          .showPublicProfile(
            context: context,
            uid: message.uid!,
          )
          .then((value) => onChange?.call()),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: borderRadius(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(T.thisIsBlockedUser.tr),
                Row(
                  children: [
                    UserDisplayName(uid: message.uid!),
                    const SizedBox(width: 8),
                    DateTimeShort(stamp: message.createdAt ?? 0),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
