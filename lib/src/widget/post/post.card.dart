import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
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
    this.shareButtonBuilder,
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
  final Widget Function(Post post)? shareButtonBuilder;

  @override
  Widget build(BuildContext context) {
    return Card(
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
                          Row(
                            children: [
                              DateTimeText(
                                dateTime: post.createdAt,
                                style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 11),
                              ),
                              DatabaseCount(
                                path: pathSeenBy(post.id), // 'posts/${post.id}/seenBy',
                                builder: (n) => n < 2
                                    ? const SizedBox.shrink()
                                    : Text(
                                        " view: $n",
                                        style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 11),
                                      ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: "report",
                      child: Text("Report"),
                    ),
                    PopupMenuItem(
                      value: 'block',
                      child: Database(
                        path: pathBlock(post.uid),
                        builder: (value, p) => Text(value == null ? tr.block : tr.unblock),
                      ),
                    ),
                  ],
                  onSelected: (value) async {
                    if (value == 'report') {
                      ReportService.instance.showReportDialog(context: context, postId: post.id);
                    } else if (value == 'block') {
                      final blocked = await toggle(pathBlock(post.uid));
                      toast(
                        title: blocked ? tr.block : tr.unblock,
                        message: blocked ? tr.blockMessage : tr.unblockMessage,
                      );
                    }
                  },
                )
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
                            StorageService.instance.showUploads(
                              context,
                              post.urls,
                            );
                          },
                          child: CachedNetworkImage(
                            imageUrl: e.thumbnail,
                            fit: BoxFit.contain,
                          ),
                        ),
                      )
                      .toList(),
                ]),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: sizeXs),
              child: Row(
                children: [
                  Database(
                    path: pathLikedBy(post.id),
                    builder: (n, p) => IconButton(
                      onPressed: () => toggle(p),
                      icon: Icon(n != null ? Icons.thumb_up : Icons.thumb_up_outlined),
                    ),
                  ),
                  FavoriteButton(
                    postId: post.id,
                    builder: (didIFavorite) {
                      return Icon(didIFavorite ? Icons.favorite : Icons.favorite_border);
                    },
                  ),
                  shareButtonBuilder?.call(post) ??
                      PostService.instance.customize.shareButtonBuilder?.call(post) ??
                      const SizedBox.shrink(),
                ],
              ),
            ),
            DatabaseCount(
              path: pathLikedBy(post.id, all: true),
              builder: (n) => n == 0 ? const SizedBox.shrink() : Text("$n likes"),
            ),
            Text(post.content.replaceAll("\n", " "), style: Theme.of(context).textTheme.bodyMedium),
            Row(
              children: [
                if (post.noOfComments > 0) Text("comments ${post.noOfComments}"),
              ],
            ),
            StreamBuilder(
              stream: commentCol
                  .where('postId', isEqualTo: post.id)
                  .orderBy('createdAt', descending: false)
                  .limitToLast(5)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  log(snapshot.error.toString());
                  return Text('Something went wrong; ${snapshot.error.toString()}');
                }
                if (snapshot.hasData) {
                  List<Widget> children = [];
                  for (final doc in snapshot.data!.docs) {
                    final comment = Comment.fromDocumentSnapshot(doc);

                    children.add(
                      OnlineComment(comment: comment),
                    );
                  }
                  return Column(
                    children: children,
                  );
                }

                return const SizedBox.shrink();
              },
            ),
            ElevatedButton(
              onPressed: () async {
                final comment = await CommentService.instance.showCommentEditBottomSheet(context, post: post);
                print(comment.toString());
              },
              child: const Text('Create comment'),
            )
          ],
        ),
      ),
    );
  }
}
