import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PostBubble extends StatefulWidget {
  const PostBubble({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  State<PostBubble> createState() => _PostBubbleState();
}

class _PostBubbleState extends State<PostBubble> {
  bool get isMine => widget.post.uid == myUid;

  bool get isLongText => (widget.post.content.length >= 99 ||
      '\n'.allMatches(widget.post.content).length > 5);

  String get content {
    if (isLongText) {
      String t = widget.post.content;
      final splits = t.split('\n');
      if (splits.length > 5) {
        return '${splits.sublist(0, 5).join('\n')}...';
      } else {
        return '${widget.post.content.substring(0, 99)}...';
      }
    } else {
      return widget.post.content;
    }
  }

  List<String> urls = [];
  @override
  void initState() {
    super.initState();

    if (widget.post.urls.isNotEmpty) {
      urls.addAll(widget.post.urls);
    }

    widget.post.urlsRef.once().then((DatabaseEvent event) {
      final value = event.snapshot.value as List<dynamic>?;

      if (value != null) {
        List<String> newValue = List<String>.from(value);
        // widget.post.urls;
        if (newValue.isNotEmpty) {
          urls.clear();
          urls.addAll(newValue);
          setState(() {});
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // To hide the [PostBubble] when the post is deleted
    if (widget.post.deleted) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine) ...[
            UserAvatar(
                uid: widget.post.uid,
                cacheId: widget.post.uid,
                size: 32,
                radius: 13,
                onTap: () => UserService.instance.showPublicProfileScreen(
                      context: context,
                      uid: widget.post.uid,
                    )),
          ],
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (widget.post.urls.isNotEmpty) ImageDisplay(urls: urls),
                if (widget.post.content.hasUrl) ...[
                  Blocked(
                    otherUserUid: widget.post.uid,
                    yes: () => const SizedBox.shrink(),
                    no: () => Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * .7,
                      ),
                      child: UrlPreview(
                        previewUrl: widget.post.previewUrl!,
                        title: widget.post.previewTitle,
                        description: widget.post.previewDescription,
                        imageUrl: widget.post.previewImageUrl,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => ForumService.instance.showPostViewScreen(
                    context: context,
                    post: widget.post,
                    commentable: false,
                  ),
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * .7,
                    ),
                    child: Column(
                      crossAxisAlignment: isMine
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: isMine
                                ? Theme.of(context).colorScheme.primary.tone(40)
                                : Theme.of(context)
                                    .colorScheme
                                    .surface
                                    .tone(93),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(!isMine
                                  ? widget.post.urls.isNotEmpty ||
                                          widget.post.content.hasUrl
                                      ? 0
                                      : 16
                                  : 16),
                              topRight: Radius.circular(isMine ? 0 : 16),
                              bottomLeft: Radius.circular(isMine ? 16 : 0),
                              bottomRight: const Radius.circular(16),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: LinkifyText(
                              content.orBlocked(
                                widget.post.uid,
                                T.blockedContentMessage.tr,
                              ),
                              selectable: false,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color: isMine
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onPrimary
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                    fontWeight: isMine
                                        ? FontWeight.w500
                                        : FontWeight.normal,
                                  ),
                              linkStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color: isMine

                                        /// [LinkifyText] is using its default color and it does not look good in terms of constrast when it is on [colorScheme.primary]
                                        /// [.withGreen(200)] matches the [Color.blue] of the [LinkifyText]
                                        ? Colors.blue.withGreen(200)
                                        : Colors.blue,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        dateAndName(context: context, post: widget.post),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  dateAndName({required BuildContext context, required Post post}) {
    return Row(
      mainAxisAlignment:
          isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (isMine) ...[
          if (post.content.hasUrl && isLongText) _readMore(),
          const Spacer(),
          _dateTime(post, context),
        ],
        UserDisplayName(
          uid: post.uid,
          style: Theme.of(context).textTheme.labelSmall!.copyWith(
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.w600,
              ),
        ),
        if (!isMine) ...[
          _dateTime(post, context),
          const Spacer(),
          if (post.content.hasUrl && isLongText) _readMore(),
        ],
      ],
    );
  }

  _dateTime(Post post, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Text(
        dateTimeShort(post.createdAt),
        style: Theme.of(context).textTheme.labelSmall!.copyWith(
              color: Theme.of(context).colorScheme.onSurface.tone(50),
            ),
      ),
    );
  }

  _readMore() {
    return Text(
      '   ${isMine ? '수정 삭제' : ''} ${T.readMore.tr}...   ',
      style: Theme.of(context)
          .textTheme
          .labelSmall!
          .copyWith(color: Colors.grey.shade600),
    );

    // if (content.length < 80) {
    //   return '';
    // }
    // return '${isMine ? '수정 삭제' : ''} ${T.readMore.tr}   ';
  }
}

class ImageDisplay extends StatelessWidget {
  const ImageDisplay({
    super.key,
    required this.urls,
  });

  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: urls
              .asMap()
              .map(
                (index, url) => MapEntry(
                  index,
                  Padding(
                    padding: EdgeInsets.only(
                        right: index == urls.length - 1 ? 0 : 8),
                    child: InkWell(
                      onTap: () => showGeneralDialog(
                        context: context,
                        pageBuilder: (_, __, ___) => PhotoViewerScreen(
                          urls: urls,
                          selectedIndex: index,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 150,
                          height: 150,
                          child: CachedNetworkImage(
                            imageUrl: url,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .values
              .toList(),
        ),
      ),
    );
  }
}
