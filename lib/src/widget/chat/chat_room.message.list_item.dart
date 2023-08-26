import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/widget/common/display_media/display_media.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter_linkify/flutter_linkify.dart';

const double _kBubblePadding = 10.0;

class ChatRoomMessageListItem extends StatelessWidget {
  const ChatRoomMessageListItem({
    super.key,
    required this.message,
  });

  final Message message;

  bool get isMyMessage => message.uid == FirebaseAuth.instance.currentUser!.uid;
  bool get isOtherMessage => !isMyMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        message.hasUrl
            ? mediaBubble(context, DisplayMedia(url: message.url!))
            : chatBubble(context, LinkifyText(text: message.text ?? '')),
        displaySitePreview(),
      ],
    );
  }

  Widget chatBubble(BuildContext context, Widget child) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 100, maxWidth: MediaQuery.of(context).size.width * 0.8),
      child: Row(
        children: [
          if (isMyMessage) chatBubbleDateTime(),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 4, bottom: 4),
              padding: const EdgeInsets.all(_kBubblePadding),
              decoration: BoxDecoration(
                color: isMyMessage ? Colors.amber.shade300 : Colors.grey.shade200,
                borderRadius: BorderRadius.only(
                  bottomLeft: const Radius.circular(8.0),
                  bottomRight: const Radius.circular(8.0),
                  topLeft: Radius.circular(isMyMessage ? 8.0 : 0),
                  topRight: Radius.circular(isMyMessage ? 0.0 : 8.0),
                ),
              ),
              child: child,
            ),
          ),
          if (isOtherMessage) chatBubbleDateTime(),
        ],
      ),
    );
  }

  Widget chatBubbleDateTime() {
    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 4),
      padding: const EdgeInsets.all(_kBubblePadding),
      child: Text(
        message.createdAt.toDate().toLocal().toString().substring(11, 16),
        style: const TextStyle(fontSize: 10, color: Colors.grey),
      ),
    );
  }

  Widget mediaBubble(BuildContext context, Widget child) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 100, maxWidth: MediaQuery.of(context).size.width * 0.8),
      child: Row(
        children: [
          if (isMyMessage) chatBubbleDateTime(),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 4, bottom: 4),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: const Radius.circular(8.0),
                  bottomRight: const Radius.circular(8.0),
                  topLeft: Radius.circular(isMyMessage ? 8 : 0),
                  topRight: Radius.circular(isMyMessage ? 0.0 : 8),
                ),
                child: child,
              ),
            ),
          ),
          if (isOtherMessage) chatBubbleDateTime(),
        ],
      ),
    );
  }

  Widget displaySitePreview() {
    if (message.hasPreview == false) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      width: 220,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.previewImageUrl != null)
              ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(imageUrl: message.previewImageUrl!)),
            const SizedBox(height: 16),
            if (message.previewTitle != null)
              Text(message.previewTitle!, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            if (message.previewDescription != null) Text(message.previewDescription!),
          ],
        ),
      ),
    );
  }
}
