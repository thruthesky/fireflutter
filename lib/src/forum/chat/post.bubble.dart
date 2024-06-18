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

  final List<String> urls = [];

  @override
  void initState() {
    super.initState();

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
            ),
          ],
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                ImageDisplay(urls: urls),
                const SizedBox(height: 8),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => ForumService.instance.showPostViewScreen(
                    context: context,
                    post: widget.post,
                    commentable: false,
                  ),
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * .7,
                    ),
                    decoration: BoxDecoration(
                      color: isMine
                          ? Theme.of(context).colorScheme.primary.tone(40)
                          : Theme.of(context).colorScheme.surface.tone(93),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: Radius.circular(isMine ? 0 : 16),
                        bottomLeft: Radius.circular(isMine ? 16 : 0),
                        bottomRight: const Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: Text(
                            widget.post.content.cut(80).orBlocked(
                                  widget.post.uid,
                                  T.blockedContentMessage.tr,
                                ),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: isMine ? Colors.white : Colors.black,
                                  fontWeight: isMine
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                dateAndName(context: context, post: widget.post),
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
        if (isMine) _dateTime(post, context),
        UserDisplayName(
          uid: post.uid,
          style: Theme.of(context).textTheme.labelSmall!.copyWith(
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(width: 8),
        if (!isMine) _dateTime(post, context),
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

  String _readMore(String content) {
    // Text(
    //   '   ${isMine ? '수정 삭제' : ''} ${T.readMore.tr}...   ',
    //   style: Theme.of(context)
    //       .textTheme
    //       .labelSmall!
    //       .copyWith(color: Colors.grey.shade600),
    // );

    if (content.length < 80) {
      return '';
    }
    return '${isMine ? '수정 삭제' : ''} ${T.readMore.tr}   ';
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: urls
            .asMap()
            .map(
              (index, url) => MapEntry(
                index,
                Padding(
                  padding:
                      EdgeInsets.only(right: index == urls.length - 1 ? 0 : 8),
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
    );
  }
}
