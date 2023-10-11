import 'dart:developer';

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
    this.margin = const EdgeInsets.fromLTRB(sizeSm, sizeSm, sizeSm, 0),
    this.clipBehavior,
    this.semanticContainer = true,
    required this.post,
    this.shareButtonBuilder,
    this.commentSize = 5,
    this.contentBackground,

    /// Can be used to change the container of the post
    this.customContainer,

    /// The topmost part of the post
    /// Custom Header Builder can be used to fully change the header of the post
    this.customHeaderBuilder,

    /// The main content of the post
    /// Custom Main Content Builder can be used to fully change the main content of the post
    this.customMainContentBuilder,

    /// The middle content of the post
    /// Use this to add content under main content and above the action buttons
    this.customMiddleContentBuilder,

    /// The action buttons of the post
    /// Custom Actions Builder can be used to fully change the action buttons of the post
    ///
    /// The default action buttons are:
    /// - Like button
    /// - Favorite button
    /// - Share button
    this.customActionsBuilder,

    /// The footer of the post
    /// Custom Footer Builder can be used to fully change the footer of the post
    ///
    /// The default footer is:
    /// - List of comments
    /// - Show more comments button
    this.customFooterBuilder,
    this.headerPadding = const EdgeInsets.fromLTRB(sizeSm, sizeSm, sizeSm, 0),
    this.bottomButtonPadding = const EdgeInsets.fromLTRB(sizeSm, 0, sizeSm, sizeSm),
  });

  final Color? color;
  final Color? shadowColor;
  final Color? surfaceTintColor;
  final double? elevation;
  final ShapeBorder? shape;
  final bool borderOnForeground;
  final Clip? clipBehavior;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry headerPadding;
  final EdgeInsetsGeometry bottomButtonPadding;
  final bool semanticContainer;

  final Color? contentBackground;

  final Post post;

  /// Callback function for share button
  final Widget Function(Post post)? shareButtonBuilder;
  final Widget Function(Widget content)? customContainer;
  final Widget Function(BuildContext context, Post post)? customHeaderBuilder;
  final Widget Function(BuildContext context, Post post)? customMainContentBuilder;
  final Widget Function(BuildContext context, Post post)? customMiddleContentBuilder;
  final Widget Function(BuildContext context, Post post)? customActionsBuilder;
  final Widget Function(BuildContext context, Post post)? customFooterBuilder;

  /// The number of comments to show
  final int commentSize;

  @override
  Widget build(BuildContext context) {
    return customContainer?.call(content(context, post)) ??
        Card(
          color: color,
          shadowColor: shadowColor,
          surfaceTintColor: surfaceTintColor,
          elevation: elevation,
          shape: shape,
          borderOnForeground: borderOnForeground,
          margin: margin,
          clipBehavior: clipBehavior,
          semanticContainer: semanticContainer,
          child: content(context, post),
        );
  }

  Widget content(BuildContext context, Post post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // custom Header
        customHeaderBuilder?.call(context, post) ?? defaultHeader(context, post),
        // custom main content
        customMainContentBuilder?.call(context, post) ?? defaultMainContent(context, post),
        // Custom Middle content
        customMiddleContentBuilder?.call(context, post) ?? const SizedBox.shrink(),
        // custom actions Builder
        customActionsBuilder?.call(context, post) ?? defaultActions(context, post),
        // custom footer builder
        customFooterBuilder?.call(context, post) ?? defaultFooter(context, post),
      ],
    );
  }

  Widget defaultHeader(BuildContext context, Post post) {
    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => UserService.instance.showPublicProfileScreen(context: context, uid: post.uid),
          child: Padding(
            padding: headerPadding,
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
                      builder: (user) => Text(user.name, style: Theme.of(context).textTheme.titleMedium),
                    ),
                    Row(
                      children: [
                        DateTimeText(
                            dateTime: post.createdAt,
                            style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 11)),
                        DatabaseCount(
                          path: pathSeenBy(post.id), // 'posts/${post.id}/seenBy',
                          builder: (n) => n < 2
                              ? const SizedBox.shrink()
                              : Text(
                                  " | Views: $n",
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
        ),
        const Spacer(),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            const PopupMenuItem(value: "reply", child: Text("Reply")),
            if (post.isMine) ...[
              PopupMenuItem(value: "edit", child: Text(tr.edit)),
              PopupMenuItem(value: "delete", child: Text(tr.delete)),
            ],
            if (!post.isMine) ...[
              const PopupMenuItem(value: "report", child: Text("Report")),
              PopupMenuItem(
                value: 'block',
                child: Database(
                  path: pathBlock(post.uid),
                  builder: (value, p) => Text(value == null ? tr.block : tr.unblock),
                ),
              ),
            ],
          ],
          onSelected: (value) async {
            if (value == "reply") {
              CommentService.instance.showCommentEditBottomSheet(context, post: post);
            } else if (value == "delete") {
              final re = await confirm(
                  context: context, title: 'Deleting Post', message: 'Are you sure you want to delete this?');
              if (re == true) {
                await post.delete(reason: 'This post has been deleted by user.');
                toast(title: tr.delete, message: tr.delete);
              }
            } else if (value == "edit") {
              PostService.instance.showEditScreen(context, post: post);
            } else if (value == 'report') {
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
    );
  }

  Widget defaultMainContent(BuildContext context, Post post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (post.hasPhoto || post.youtubeId.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: sizeSm),
            child: CarouselView(
              widgets: [
                if (post.youtubeId.isNotEmpty)
                  GestureDetector(
                    onTap: () => showPreview(context, 0),
                    child: YouTubeThumbnail(
                      youtubeId: post.youtubeId,
                      stackFit: StackFit.passthrough,
                      boxFit: BoxFit.cover,
                    ),
                  ),
                if (post.hasPhoto)
                  ...post.urls
                      .asMap()
                      .entries
                      .map(
                        (e) => GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => showPreview(context, post.youtubeId.isNotEmpty ? e.key + 1 : e.key),
                          child: CachedNetworkImage(
                            imageUrl: e.value,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const SizedBox(height: 400),
                          ),
                        ),
                      )
                      .toList()
              ],
            ),
          ),

        /// post titile
        if (post.title.isNotEmpty)
          Container(
            padding: const EdgeInsets.fromLTRB(sizeSm, sizeSm, sizeSm, 0),
            color: contentBackground,
            child: Text(post.title.replaceAll("\n", " "), style: Theme.of(context).textTheme.titleMedium),
          ),

        /// post content
        if (post.content.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(sizeSm),
            color: contentBackground,
            child: post.content.length < 60
                ? Text(post.content.replaceAll("\n", " "), style: Theme.of(context).textTheme.bodyMedium)
                : PostContentShowMore(post: post),
          ),
      ],
    );
  }

  List<Widget> listMedia(BuildContext context) {
    return [
      if (post.youtubeId.isNotEmpty)
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  insetPadding: const EdgeInsets.all(0),
                  contentPadding: const EdgeInsets.all(0),
                  content: YouTube(youtubeId: post.youtubeId),
                );
              },
            );
          },
          child: YouTubeThumbnail(
            key: ValueKey(post.youtubeId),
            youtubeId: post.youtubeId,
            stackFit: StackFit.passthrough,
          ),
        ),
      ...post.urls.map((e) => CachedNetworkImage(imageUrl: e)).toList()
    ];
  }

  Widget defaultActions(BuildContext context, Post post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: sizeXs),
          child: Row(
            children: [
              IconButton(
                  onPressed: () => CommentService.instance.showCommentEditBottomSheet(context, post: post),
                  icon: const Icon(Icons.reply)),
              Database(
                path: pathPostLikedBy(post.id),
                builder: (v, p) => IconButton(
                  onPressed: () => post.like(),
                  icon: Icon(v != null ? Icons.favorite : Icons.favorite_outline),
                ),
              ),
              FavoriteButton(
                postId: post.id,
                builder: (re) => Icon(re ? Icons.bookmark : Icons.bookmark_border),
                onChanged: (re) => toast(
                  title: re ? tr.favorite : tr.unfavorite,
                  message: re ? tr.favoriteMessage : tr.unfavoriteMessage,
                ),
              ),
              shareButtonBuilder?.call(post) ??
                  PostService.instance.customize.shareButtonBuilder?.call(post) ??
                  const SizedBox.shrink(),
            ],
          ),
        ),
        // like button
        Database(
          path: pathPostLikedBy(post.id, all: true),
          builder: (n, str) {
            final likes = Map<String, bool?>.from(n ?? {});

            return likes.isEmpty
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: sizeSm,
                    ),
                    child: GestureDetector(
                      child: Text("${likes.length} likes"),
                      onTap: () {
                        UserService.instance.showLikedByListScreen(
                          context: context,
                          uids: likes.keys.toList(),
                        );
                      },
                    ),
                  );
          },
        ),
      ],
    );
  }

  Widget defaultFooter(BuildContext context, Post post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // post & comment buttons
        if (post.noOfComments > commentSize) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Row(
              children: [
                TextButton(
                  onPressed: () {
                    CommentService.instance.showCommentListBottomSheet(context, post);
                  },
                  child: Text(tr.showMoreComments.replaceAll("#no", post.noOfComments.toString())),
                ),
              ],
            ),
          ),
        ],
        // list of comment
        StreamBuilder(
          stream: commentCol
              .where('postId', isEqualTo: post.id)
              .orderBy('sort', descending: false)
              .limitToLast(commentSize)
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
                  CommentOneLineListTile(
                    padding: const EdgeInsets.fromLTRB(sizeSm, sizeSm, sizeSm, 0),
                    contentMargin: const EdgeInsets.only(bottom: 8),
                    contentBorderRadius: const BorderRadius.all(Radius.circular(8)),
                    post: post,
                    comment: comment,
                    onTapContent: () => CommentService.instance.showCommentListBottomSheet(context, post),
                  ),
                );
              }
              //
              return Column(children: children);
            }
            return const SizedBox.shrink();
          },
        ),
        // post & comment buttons
        Padding(
          padding: bottomButtonPadding,
          child: const Row(
            children: [
              //
            ],
          ),
        )
      ],
    );
  }

  void showPreview(BuildContext context, int index) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) {
        return CarouselScreen(
          widgets: listMedia(context),
          index: index,
        );
      },
    );
  }
}
