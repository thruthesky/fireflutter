import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ActivityLogTimeLineComment extends StatelessWidget {
  const ActivityLogTimeLineComment({super.key, required this.activity});

  final ActivityLog activity;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 160),
      child: PostDoc(
        live: false,
        onLoading: const SizedBox(height: 160),
        postId: activity.postId,
        builder: (Post post) {
          return UserDoc(
            uid: activity.uid,
            onLoading: const SizedBox(height: 100),
            builder: (actor) {
              return ActivityLogListTiLeItem(
                activity: activity,
                actor: actor,
                message: switch (activity.action) {
                  'create' => tr.createCommentLog.replace({
                      '#a': actor.getDisplayName,
                    }),
                  'update' => tr.updateCommentLog.replace({
                      '#a': actor.getDisplayName,
                    }),
                  'delete' => tr.deleteCommentLog.replace({
                      '#a': actor.getDisplayName,
                    }),
                  'like' => tr.likedCommentLog.replace({
                      '#a': actor.getDisplayName,
                    }),
                  'unlike' => tr.unlikedCommentLog.replace({
                      '#a': actor.getDisplayName,
                    }),
                  _ => '${actor.getDisplayName} ${activity.type} ${activity.action} ',
                },
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => PostService.instance.showPostViewScreen(context: context, post: post),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                              " | ${tr.views}: $n",
                                              style: TextStyle(
                                                  color: Theme.of(context).colorScheme.secondary, fontSize: 11),
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
                        const SizedBox(height: sizeSm),
                        Text(post.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: sizeXxs),
                        Text(post.content,
                            maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
                        if (post.noOfComments > 0)
                          TextButton(
                            style: ButtonStyle(
                              padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
                              visualDensity: VisualDensity.compact,
                              textStyle: MaterialStateProperty.all(Theme.of(context).textTheme.bodySmall),
                            ),
                            onPressed: () {
                              CommentService.instance.showCommentListBottomSheet(context, post);
                            },
                            child: Text(tr.showMoreComments.replaceAll("#no", post.noOfComments.toString())),
                          ),
                        FutureBuilder(
                          future: Comment.get(activity.commentId!),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              dog(snapshot.error.toString());
                              return Text('Something went wrong; ${snapshot.error.toString()}');
                            }
                            if (snapshot.hasData) {
                              Comment comment = snapshot.data!;
                              return CommentOneLineListTile(
                                key: ValueKey(comment.id),
                                fixedDepth: 0,
                                hideActionButton: true,
                                hideLikeButton: true,
                                post: post,
                                comment: comment,
                                onTapContent: () => CommentService.instance.showCommentListBottomSheet(context, post),
                              );
                            }
                            return const SizedBox(
                              height: 44,
                            );
                          },
                        ),
                      ],
                    ),
                  )
                ],
              );
            },
          );
        },
      ),
    );
  }
}
