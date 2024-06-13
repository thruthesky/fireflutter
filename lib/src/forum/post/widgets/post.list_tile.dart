import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// A list tile for the post list view.
///
/// Use this widget to display a post as a ListTile.
class PostListTile extends StatelessWidget {
  const PostListTile({
    super.key,
    required this.post,
    this.tight = false,
  });

  final Post post;
  final bool tight;

  /// A small (tight) version of the post list tile.

  PostListTile.small({
    super.key,
    required this.post,
  }) : tight = true;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: UserAvatar(
        size: tight ? 32 : 48,
        radius: tight ? 14 : 20,
        uid: post.uid,
        onTap: () => UserService.instance.showPublicProfileScreen(
          context: context,
          uid: post.uid,
        ),
        cacheId: 'post.list.tile',
      ),
      title: Text(
        post.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        post.content.upTo(60).sanitize,
        maxLines: tight ? 1 : 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          post.noOfComments > 0
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Badge.count(
                    count: post.noOfComments,
                    textColor: Theme.of(context).colorScheme.onSecondary,
                    backgroundColor:
                        Theme.of(context).colorScheme.secondary.tone(50),
                  ),
                )
              : const SizedBox.shrink(),
          Text(
            post.createdAt.millisecondsSinceEpoch.toHis,
          ),
        ],
      ),
      onTap: () => ForumService.instance.showPostViewScreen(
        context: context,
        post: post,
      ),
    );
  }
}
