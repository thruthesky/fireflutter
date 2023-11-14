import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// Buttons on post view screen.
///
/// You can add more buttons using [leading], [trailing], [middle].
///
/// Note that, [trailing] must be a listing of [PopupMenuEntry<String>] which
/// will be added at the bottom of the popup menu.
///
class PostViewButtons extends StatelessWidget {
  const PostViewButtons({
    super.key,
    required this.post,
    this.leading,
    this.trailing,
    this.middle,
  });

  final Post? post;

  /// Buttons on the left side of the buttons.
  final List<Widget>? leading;

  /// Buttons on the right side of the buttons.
  final List<PopupMenuEntry<String>>? trailing;

  /// Buttons in the middle of the buttons.
  final List<Widget>? middle;

  @override
  Widget build(BuildContext context) {
    return post == null
        ? const LoginFirst()
        : Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ...?leading,
              TextButton(
                child: Text(tr.reply),
                onPressed: () async {
                  await CommentService.instance.showCommentEditBottomSheet(
                    context,
                    post: post,
                  );
                },
              ),
              PostDoc(
                postId: post!.id,
                post: post,
                builder: (post) => TextButton(
                  child: Text(
                    post.likes.isEmpty
                        ? tr.like
                        : tr.likes
                            .replaceAll('#no', post.likes.length.toString()),
                  ),
                  onPressed: () => post.like(),
                ),
              ),
              MyDoc(
                builder: (user) => TextButton(
                  onPressed: () async {
                    final re = await FeedService.instance.follow(post!.uid);
                    toast(
                      title: re ? tr.favorite : tr.unfavorite,
                      message: re ? tr.favoriteMessage : tr.unfavoriteMessage,
                    );
                  },
                  child: Text(user.followings.contains(post!.uid)
                      ? tr.unfollow
                      : tr.follow),
                ),
              ),
              ...?middle,
              const Spacer(),
              PopupMenuButton<String>(
                itemBuilder: (_) => [
                  if (post!.isMine)
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'report', child: Text('Report')),
                  if (loggedIn)
                    PopupMenuItem(
                      value: 'block',
                      child: Database(
                        path: pathBlock(post!.uid),
                        builder: (value, p) =>
                            Text(value == null ? tr.block : tr.unblock),
                      ),
                    ),
                  ...?trailing,
                ],
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Icon(Icons.more_horiz),
                ),
                onSelected: (v) async {
                  if (v == 'edit') {
                    await PostService.instance
                        .showEditScreen(context, post: post);
                  } else if (v == 'report') {
                    ReportService.instance.showReportDialog(
                      context: context,
                      postId: post!.id,
                      onExists: (id, type) => toast(
                          title: 'Already reported',
                          message: 'You have reported this $type already.'),
                    );
                  } else if (v == 'block') {
                    final blocked = await toggle(pathBlock(post!.uid));
                    toast(
                      title: blocked ? tr.block : tr.unblock,
                      message: blocked ? tr.blockMessage : tr.unblockMessage,
                    );
                  }
                },
              ),
            ],
          );
  }
}
