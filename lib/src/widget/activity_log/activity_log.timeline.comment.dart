import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/widget/activity_log/activity_log.list_view.item.dart';
import 'package:flutter/material.dart';

class ActivityLogTimeLineComment extends StatelessWidget {
  const ActivityLogTimeLineComment({super.key, required this.activity});

  final ActivityLog activity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: PostDoc(
        key: Key(activity.id),
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
