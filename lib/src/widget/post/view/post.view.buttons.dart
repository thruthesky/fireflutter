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
                child: const Text('Reply'),
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
                    'Like ${post.noOfLikes}',
                    style: post.iLiked
                        ? const TextStyle(fontWeight: FontWeight.bold)
                        : null,
                  ),
                  onPressed: () => post.like(),
                ),
              ),
              UserDoc(
                live: true,
                builder: (user) => TextButton(
                  onPressed: () async {
                    final re = await FeedService.instance.follow(post!.uid);
                    toast(
                      title: re ? 'Followed' : 'Unfollowed',
                      message: re
                          ? 'You have followed this user'
                          : 'You have unfollowed this user',
                    );
                  },
                  child: Text(user.followings.contains(post!.uid)
                      ? 'Unfollow'
                      : 'Follow'),
                ),
              ),
              ...?middle,
              const Spacer(),
              PopupMenuButton<String>(
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'report', child: Text('Report')),
                  PopupMenuItem(
                    value: 'block',
                    child: Database(
                      path: 'settings/$myUid/blocks/${post!.uid}',
                      builder: (value) =>
                          Text(value == null ? tr.menu.block : tr.menu.unblock),
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
                        .showEditDialog(context, post: post);
                  } else if (v == 'report') {
                    ReportService.instance.showReportDialog(
                      context: context,
                      postId: post!.id,
                      onExists: (id, type) => toast(
                          title: 'Already reported',
                          message: 'You have reported this $type already.'),
                    );
                  } else if (v == 'block') {
                    final blocked =
                        await toggle('/settings/$myUid/blocks/${post!.uid}');
                    toast(
                      title: blocked ? tr.menu.block : tr.menu.unblock,
                      message: blocked
                          ? tr.menu.blockMessage
                          : tr.menu.unblockMessage,
                    );
                  }
                },
              ),
            ],
          );
  }
}
