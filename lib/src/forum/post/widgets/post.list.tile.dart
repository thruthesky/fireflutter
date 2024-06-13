import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PostListTile extends StatelessWidget {
  const PostListTile({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: UserAvatar(
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
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        // mainAxisAlignment: MainAxisAlignment.end,
        children: [
          post.noOfComments > 0
              ? Padding(
                  padding: const EdgeInsets.only(top: 8, right: 8),
                  child: Badge.count(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    count: post.noOfComments,
                    textColor: Theme.of(context).colorScheme.onSecondary,
                    backgroundColor:
                        Theme.of(context).colorScheme.secondary.tone(60),
                  ),
                )
              : const SizedBox.shrink(),
          const Spacer(),
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
