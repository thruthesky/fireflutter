import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// A widget that display comment in one line.
///
///
class CommentOneLineListTile extends StatelessWidget {
  const CommentOneLineListTile({
    super.key,
    required this.post,
    required this.comment,
    this.padding,
    this.contentPadding,
    this.contentMargin,
    this.contentBorderRadius,
    this.runSpacing = 8,
    this.onTapContent,
  });

  final Post post;
  final Comment comment;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? contentMargin;
  final BorderRadiusGeometry? contentBorderRadius;
  final double runSpacing;

  /// Callback function for content tap
  final void Function()? onTapContent;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: indent(comment.depth)),
      padding: padding ?? const EdgeInsets.all(0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAvatar(
            uid: comment.uid,
            radius: 10,
            size: 24,
            onTap: () => UserService.instance.showPublicProfileScreen(
              context: context,
              uid: comment.uid,
            ),
          ),
          SizedBox(width: runSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserDoc(
                      uid: comment.uid,
                      builder: (user) => Text(
                        user.name,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                    SizedBox(width: runSpacing),
                    DateTimeText(
                      dateTime: comment.createdAt,
                      style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 11),
                    ),
                  ],
                ),

                // photos of the comment
                if (comment.urls.isNotEmpty)
                  SizedBox(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: comment.urls
                          .asMap()
                          .entries
                          .map(
                            (e) => GestureDetector(
                              onTap: () => StorageService.instance.showUploads(
                                context,
                                comment.urls,
                                index: e.key,
                              ),
                              child: CachedNetworkImage(
                                imageUrl: e.value.thumbnail,
                                fit: BoxFit.contain,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onTapContent,
                  child: Container(
                    margin: contentMargin ?? const EdgeInsets.all(0),
                    padding: contentPadding ?? const EdgeInsets.all(0),
                    width: double.infinity,
                    // decoration: BoxDecoration(
                    //   color: Theme.of(context).colorScheme.surface,
                    //   borderRadius: contentBorderRadius ?? BorderRadius.circular(8),
                    // ),
                    child: Text(
                      comment.content,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    // no of likes
                    DatabaseCount(
                      path: pathCommentLikedBy(comment.id, all: true),
                      builder: (n) => n == 0
                          ? const SizedBox.shrink()
                          : TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.only(left: 0, right: 8),
                                minimumSize: Size.zero,
                                visualDensity: VisualDensity.compact,
                              ),
                              onPressed: () async => UserService.instance.showLikedByListScreen(
                                context: context,
                                uids: await getKeys(pathCommentLikedBy(comment.id, all: true)),
                              ),
                              child: Text(
                                n == 0
                                    ? tr.like
                                    : tr.noOfLikes.replaceAll(
                                        '#no',
                                        n.toString(),
                                      ),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                    ),
                    // reply
                    // TODO make sure the post to pass to reply comment is the latest
                    // TODO really need to review because sort is not working properly
                    // Added a git issue. Remove the TODOs above only if resolved -dev2
                    // https://github.com/users/thruthesky/projects/9/views/29?pane=issue&itemId=40127135
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.only(left: 0, right: 8),
                        minimumSize: Size.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: () {
                        CommentService.instance.showCommentEditBottomSheet(
                          context,
                          post: post,
                          parent: comment,
                        );
                      },
                      child: Text(
                        tr.reply,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await CommentService.instance.showCommentEditBottomSheet(context, comment: comment, post: post);
                      },
                      child: Text(tr.edit),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Database(
            path: pathCommentLikedBy(comment.id),
            builder: (value, path) => IconButton(
              onPressed: () => comment.like(),
              icon: Icon(
                value == null ? Icons.favorite_border : Icons.favorite,
                size: 16,
                color: value == null ? null : Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
