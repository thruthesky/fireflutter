import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class CommentListTile extends StatefulWidget {
  const CommentListTile({
    super.key,
    required this.comment,
  });

  final Comment comment;

  @override
  State<CommentListTile> createState() => _CommentListTileState();
}

class _CommentListTileState extends State<CommentListTile> {
  double lineWidth = 2;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserAvatar(
              uid: widget.comment.uid,
              size: 32,
              onTap: () => UserService.instance.showPublicProfileScreen(
                context: context,
                uid: widget.comment.uid,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      UserDisplayName(
                        uid: widget.comment.uid,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.comment.createdAt.toShortDate,
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                              fontSize: 10,
                            ),
                      ),
                    ],
                  ),
                  CommentContent(comment: widget.comment),
                  Blocked(
                    otherUserUid: widget.comment.uid,
                    yes: () => SizedBox.fromSize(),
                    no: () => Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      children: widget.comment.urls
                          .asMap()
                          .map(
                            (index, url) => MapEntry(
                              index,
                              GestureDetector(
                                onTap: () => showGeneralDialog(
                                  context: context,
                                  pageBuilder: (_, __, ___) =>
                                      PhotoViewerScreen(
                                    urls: widget.comment.urls,
                                    selectedIndex: index,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: url,
                                    fit: BoxFit.cover,
                                    width: widget.comment.urls.length == 1
                                        ? 200
                                        : 100,
                                    height: 200,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .values
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
