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
          if (!message.mine)
            UserDoc(
                uid: message.uid!,
                live: true,
                builder: (user) {
                  return PopupMenuButton(
                    itemBuilder: (context) {
                      return [
                        if (my!.isAdmin)
                          PopupMenuItem(
                            value: 'disable',
                            child: Text(enableOrDisableText(user.isDisabled)),
                          )
                      ];
                    },
                    onSelected: (value) async {
                      if (value == 'disable') {
                        final re = await confirm(
                          context: context,
                          title: "${enableOrDisableText(user.isDisabled)} User",
                          message: 'Are you sure you want to ${enableOrDisableText(user.isDisabled)} this user?',
                        );
                        if (re != true) return;
                        user.isDisabled ? await user.enable() : await user.disable();
                      }
                    },
                    child: UserAvatar(
                      uid: message.uid,
                      radius: 13,
                    ),
                  );
                }),

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
              child: Text(message.text ?? ''),
            ),
          // image
          if (message.url != null)
            ClipRRect(
              borderRadius: borderRadius(),
              child: Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
                child: CachedNetworkImage(
                  imageUrl: message.url!.thumbnail,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                  // if thumbnail is not available, show original image
                  errorWidget: (context, url, error) => CachedNetworkImage(imageUrl: message.url!),
                ),
              ),
            ),

          const SizedBox(width: 8),
          // my avtar
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

  String enableOrDisableText(bool isDisabled) {
    return isDisabled ? 'Enable' : 'Disable';
  }
}
