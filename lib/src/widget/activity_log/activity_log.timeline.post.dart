import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/widget/activity_log/activity_log.list_view.item.dart';
import 'package:flutter/material.dart';

class ActivityLogTimeLinePost extends StatelessWidget {
  const ActivityLogTimeLinePost({super.key, required this.activity});

  final ActivityLog activity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: PostDoc(
        key: Key(activity.postId!),
        postId: activity.postId,
        builder: (Post post) {
          return UserDoc(
            uid: activity.uid,
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
                  PostCard(
                    post: post,
                    commentSize: 0,
                    customActionsBuilder: (context, post) => const SizedBox.shrink(),
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
