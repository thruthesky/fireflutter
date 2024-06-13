import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PostBubble extends StatelessWidget {
  const PostBubble({
    super.key,
    required this.post,
  });

  final Post post;
  bool get isMine => post.uid == myUid;
  @override
  Widget build(BuildContext context) {
    if (post.deleted) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMine) dateAndName(context: context, post: post),
          GestureDetector(
            onTap: () => ForumService.instance
                .showPostViewScreen(context: context, post: post),
            child: Container(
              clipBehavior: Clip.antiAlias,
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * .6,
              ),
              decoration: BoxDecoration(
                color: isMine ? Colors.amber.shade200 : Colors.grey.shade200,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isMine ? 16 : 0),
                  topRight: Radius.circular(isMine ? 0 : 16),
                  bottomLeft: const Radius.circular(16),
                  bottomRight: const Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post.urls.isNotEmpty)
                    CachedNetworkImage(imageUrl: post.urls.first),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: LinkifyText(
                      selectable: false,
                      post.content
                          .orBlocked(
                            post.uid,
                            T.blockedContentMessage.tr,
                          )
                          .cut(80),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!isMine) dateAndName(context: context, post: post),
        ],
      ),
    );
  }

  dateAndName({required BuildContext context, required Post post}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMine) ...[
              UserAvatar(
                uid: post.uid,
                cacheId: post.uid,
              ),
              const SizedBox(height: 8),
            ],
            DateTimeShort(
              dateTime: post.createdAt,
            ),
            const SizedBox(width: 2),
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.2,
              ),
              child: UserDisplayName(
                uid: post.uid,
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                      overflow: TextOverflow.ellipsis,
                      fontSize: 11,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
