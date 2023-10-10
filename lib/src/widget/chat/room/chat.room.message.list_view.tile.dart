import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:photo_view/photo_view.dart';

const double _kBubblePadding = 10.0;

class ChatRoomMessageListViewTile extends StatefulWidget {
  const ChatRoomMessageListViewTile({
    super.key,
    required this.message,
  });

  final Message message;

  @override
  State<ChatRoomMessageListViewTile> createState() => _ChatRoomMessageListViewTileState();
}

class _ChatRoomMessageListViewTileState extends State<ChatRoomMessageListViewTile> {
  User? otherUserData;

  bool get isMyMessage => widget.message.uid == FirebaseAuth.instance.currentUser!.uid;

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
              widget.message.isUserChanged
                  ? UserAvatar(
                      padding: const EdgeInsets.fromLTRB(0, 0, 6, 6),
                      uid: widget.message.uid,
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
                    widget.message.isUserChanged
                        ? (otherUserData == null
                            ? UserDoc(
                                uid: widget.message.uid,
                                builder: (user) {
                                  otherUserData = user;
                                  return Text(
                                    user.name,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              )
                            : Text(
                                otherUserData!.name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ))
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
    if (widget.message.isProtocol == false) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4, bottom: 4),
            padding: const EdgeInsets.all(_kBubblePadding),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.inversePrimary,
              borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            ),
            child: LinkifyText(text: widget.message.text ?? widget.message.protocol ?? ''),
          ),
          chatBubbleDateTime(
            short: false,
            padding: const EdgeInsets.only(
              top: 0,
              bottom: _kBubblePadding,
            ),
          ),
        ],
      ),
    );
  }

  Widget messageBubble(BuildContext context) {
    if (widget.message.isProtocol || widget.message.text == null || widget.message.text!.trim() == '') {
      return const SizedBox.shrink();
    }
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
            text: widget.message.text ?? '',
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
            ? widget.message.createdAt.toLocal().toString().substring(11, 16)
            : widget.message.createdAt.toLocal().toString().substring(0, 16),
        style: const TextStyle(fontSize: 10, color: Colors.grey),
      ),
    );
  }

  Widget mediaBubble(BuildContext context) {
    if (widget.message.hasUrl == false) return const SizedBox.shrink();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => Stack(
            children: [
              PhotoView(
                imageProvider: CachedNetworkImageProvider(widget.message.url!),
                heroAttributes: PhotoViewHeroAttributes(tag: 'image-${widget.message.id}'),
                // onTapDown: (context, details, controllerValue) => Navigator.of(context).pop(),
              ),
              SafeArea(
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
      child: ConstrainedBox(
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
                  child: Hero(
                    tag: 'image-${widget.message.id}',
                    child: CachedNetworkImage(
                      imageUrl: widget.message.url!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            if (isOtherMessage) chatBubbleDateTime(),
          ],
        ),
      ),
    );
  }

  Widget displaySitePreview() {
    if (widget.message.hasPreview == false) return const SizedBox.shrink();
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
            if (widget.message.previewImageUrl != null)
              ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(imageUrl: widget.message.previewImageUrl!)),
            const SizedBox(height: 16),
            if (widget.message.previewTitle != null)
              Text(widget.message.previewTitle!, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            if (widget.message.previewDescription != null) Text(widget.message.previewDescription!),
          ],
        ),
      ),
    );
  }
}
