import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;

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
        protocolBubble(context),
        if (isMyMessage) ...[
          mediaBubble(context),
          messageBubble(context),
          displaySitePreview(),
        ],
        if (isOtherMessage)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              message.isUserChanged
                  ? UserAvatar(
                      padding: const EdgeInsets.fromLTRB(0, 0, 6, 6),
                      uid: message.uid,
                      size: 40,
                      radius: 10,
                      borderWidth: 0,
                      borderColor: Colors.transparent,
                    )
                  : const SizedBox(width: 40),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    message.isUserChanged
                        ? UserDoc(
                            uid: message.uid,
                            builder: (user) => Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                    mediaBubble(context),
                    messageBubble(context),
                    displaySitePreview(),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget protocolBubble(BuildContext context) {
    if (message.isProtocol == false) return const SizedBox.shrink();

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4, bottom: 4),
          padding: const EdgeInsets.all(_kBubblePadding),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.inversePrimary,
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          ),
          child: LinkifyText(text: message.text ?? ''),
        ),
        chatBubbleDateTime(
            short: false,
            padding: const EdgeInsets.only(
              top: 0,
              bottom: _kBubblePadding,
            )),
      ],
    );
  }

  Widget messageBubble(BuildContext context) {
    if (message.text == null || message.text!.trim() == '') return const SizedBox.shrink();
    final double factor = MediaQuery.of(context).size.width < 400 ? .64 : (isMyMessage ? .76 : .68);

    return Row(
      mainAxisAlignment: isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (isMyMessage) chatBubbleDateTime(),
        Container(
          constraints: BoxConstraints(minWidth: 100, maxWidth: MediaQuery.of(context).size.width * factor),
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
          child: LinkifyText(
            text: message.text ?? '',
            maxLines: 10,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (isOtherMessage) chatBubbleDateTime(),
      ],
    );
  }

  Widget chatBubbleDateTime({
    EdgeInsets padding = const EdgeInsets.all(_kBubblePadding),
    bool short = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 4),
      padding: padding,
      child: Text(
        short
            ? message.createdAt.toDate().toLocal().toString().substring(11, 16)
            : message.createdAt.toDate().toLocal().toString().substring(0, 16),
        style: const TextStyle(fontSize: 10, color: Colors.grey),
      ),
    );
  }

  Widget mediaBubble(BuildContext context) {
    if (message.hasUrl == false) return const SizedBox.shrink();

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
                child: DisplayMedia(url: message.url!),
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
