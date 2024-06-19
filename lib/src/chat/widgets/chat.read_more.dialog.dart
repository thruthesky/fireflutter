import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ChatReadMoreDialog extends StatelessWidget {
  const ChatReadMoreDialog({
    super.key,
    required this.message,
  });

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          UserAvatar(
            key: ValueKey(message.key),
            uid: message.uid!,
            cacheId: message.uid,
            size: 30,
            radius: 12,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DateTimeShort(stamp: message.createdAt ?? 0),
              const SizedBox(width: 4),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.2,
                ),
                child: UserDisplayName(
                  uid: message.uid,
                  cacheId: 'chatRoom',
                  style: Theme.of(context).textTheme.labelSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (my?.hasBlocked(message.uid ?? "") == true)
              Text(T.blockedContentMessage.tr)
            else ...[
              if (message.text != null) LinkifyText(message.text!),
              if (message.url != null)
                ClipRRect(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(16),
                  ),
                  child: Container(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.6),
                    child: CachedNetworkImage(
                      imageUrl: message.url!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                      // if thumbnail is not available, show original image
                      errorWidget: (context, url, error) {
                        return const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                        );
                      },
                      errorListener: (value) => dog(
                          'chat.read_more.dialog.dart: Image has problem:  $value'),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
