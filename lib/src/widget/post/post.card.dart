import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// Post card widget
///
/// This is a card widget that shows a post. It is used to list posts. It may
/// also be used to show a post in a post view screen.
///
/// Since it is a card wigdet, it supports all card properties (except [child])
/// and plus some additional properties for post view widget.
///
/// Note that, the height of the card is fixed based on the content. If the
/// post has photo, then the height is 300, otherwise it is 200.
///
///
class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    this.color,
    this.shadowColor,
    this.surfaceTintColor,
    this.elevation,
    this.shape,
    this.borderOnForeground = true,
    this.margin,
    this.clipBehavior,
    this.semanticContainer = true,
    required this.post,
    this.padding = const EdgeInsets.all(16),
    required this.onTapShareButton,
  });

  final Color? color;
  final Color? shadowColor;
  final Color? surfaceTintColor;
  final double? elevation;
  final ShapeBorder? shape;
  final bool borderOnForeground;
  final Clip? clipBehavior;
  final EdgeInsetsGeometry? margin;
  final bool semanticContainer;

  final Post post;
  final EdgeInsetsGeometry? padding;

  /// Callback function for share button
  final Function(Post post) onTapShareButton;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: post.hasPhoto ? 380 : 240,
      child: Card(
        color: color,
        shadowColor: shadowColor,
        surfaceTintColor: surfaceTintColor,
        elevation: elevation,
        shape: shape,
        borderOnForeground: borderOnForeground,
        margin: margin ?? const EdgeInsets.fromLTRB(16, 16, 16, 0),
        clipBehavior: clipBehavior,
        semanticContainer: semanticContainer,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => UserService.instance.showPublicProfileScreen(context: context, uid: post.uid),
                    child: Row(
                      children: [
                        UserAvatar(
                          uid: post.uid,
                          radius: 20,
                          size: 40,
                        ),
                        const SizedBox(width: sizeXs),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            UserDoc(
                              uid: post.uid,
                              builder: (user) => Text(
                                user.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            DateTimeText(
                              dateTime: post.createdAt,
                              style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                      itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: "report",
                              child: Text("Report"),
                            ),
                            PopupMenuItem(
                              value: "block",
                              child: Text("Block"),
                            ),
                          ],
                      onSelected: (value) => toast(title: '@todo', message: 'report or block post'))
                ],
              ),
              YouTubeThumbnail(youtubeId: post.youtubeId),
              if (post.hasPhoto)
                SizedBox(
                  height: 160,
                  child: ListView(scrollDirection: Axis.horizontal, children: [
                    ...post.urls
                        .map(
                          (e) => GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              toast(title: '@todo gallery carousel', message: 'make this photos as carouse widget');
                            },
                            child: CachedNetworkImage(imageUrl: e),
                          ),
                        )
                        .toList(),
                  ]),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: sizeXs),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => post.like(),
                      icon: const Icon(Icons.thumb_up),
                    ),
                    FavoriteButton(
                      postId: post.id,
                      builder: (didIFavorite) {
                        return Icon(didIFavorite ? Icons.favorite : Icons.favorite_border);
                      },
                    ),
                    IconButton(
                      onPressed: () => onTapShareButton(post),
                      icon: const Icon(Icons.share),
                    ),
                  ],
                ),
              ),
              Text(post.content.replaceAll("\n", " "), style: Theme.of(context).textTheme.bodySmall),
              Row(
                children: [
                  DatabaseCount(
                    path: 'posts/${post.id}/seenBy',
                    builder: (n) => n == 0 ? const SizedBox.shrink() : Text("View: $n"),
                  ),
                  if (post.noOfComments > 0) Text("comments ${post.noOfComments}"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
