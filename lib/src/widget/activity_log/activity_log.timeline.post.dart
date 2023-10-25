import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/widget/activity_log/activity_log.list_view.item.dart';
import 'package:flutter/material.dart';

class ActivityLogTimeLinePost extends StatelessWidget {
  const ActivityLogTimeLinePost({super.key, required this.activity});

  final ActivityLog activity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: PostDoc(
        live: false,
        onLoading: const SizedBox(height: 284),
        postId: activity.postId,
        builder: (Post post) {
          return UserDoc(
            uid: activity.uid,
            onLoading: const SizedBox(height: 120),
            builder: (actor) {
              return ActivityLogListTiLeItem(
                activity: activity,
                actor: actor,
                message: switch (activity.action) {
                  'create' => tr.createPostLog.replace({'#a': actor.getDisplayName}),
                  'update' => tr.updatePostLog.replace({'#a': actor.getDisplayName}),
                  'delete' => tr.deletePostLog.replace({'#a': actor.getDisplayName}),
                  'like' => tr.likedPostLog.replace({'#a': actor.getDisplayName}),
                  'unlike' => tr.unlikedPostLog.replace({'#a': actor.getDisplayName}),
                  _ => '${actor.getDisplayName} ${activity.type} ${activity.action}',
                },
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(),
                  ),
                  Row(
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
                          UserDisplayName(
                            uid: post.uid,
                            style: Theme.of(context).textTheme.bodyMedium,
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
                      const Spacer(),
                      if (post.hasPhoto)
                        const Icon(
                          Icons.image_outlined,
                        ),
                    ],
                  ),
                  const SizedBox(height: sizeXxs),
                  PostTitle(post: post),
                  const SizedBox(height: sizeXxs),
                  PostContent(post: post),
                  if (post.noOfComments > 0)
                    TextButton(
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: () {
                        CommentService.instance.showCommentListBottomSheet(context, post);
                      },
                      child: Text(tr.showMoreComments.replaceAll("#no", post.noOfComments.toString())),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
