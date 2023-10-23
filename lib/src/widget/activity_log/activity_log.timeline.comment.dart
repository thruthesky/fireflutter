import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/model/activity_log/activity_log.dart';
import 'package:fireflutter/src/model/activity_log/activity_log.type.dart';
import 'package:flutter/material.dart';

class ActivityLogTimeLineComment extends StatelessWidget {
  const ActivityLogTimeLineComment({super.key, required this.activity});

  final ActivityLog activity;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: PostDoc(
          key: Key(activity.id),
          postId: activity.postId,
          builder: (Post post) {
            return UserDoc(
              uid: activity.uid,
              builder: (actor) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        UserAvatar(user: actor),
                        const SizedBox(width: 8),
                        if (activity.action == Log.comment.create)
                          Text(tr.createCommentLog.replace({
                            '#a': actor.getDisplayName,
                          })),
                        if (activity.action == Log.comment.update)
                          Text(tr.updateCommentLog.replace({
                            '#a': actor.getDisplayName,
                          })),
                        if (activity.action == Log.comment.delete)
                          Text(tr.deleteCommentLog.replace({
                            '#a': actor.getDisplayName,
                          })),
                        if (activity.action == Log.comment.like)
                          Text(tr.likedCommentLog.replace({
                            '#a': actor.getDisplayName,
                          })),
                        if (activity.action == Log.comment.unlike)
                          Text(tr.unlikedCommentLog.replace({
                            '#a': actor.getDisplayName,
                          })),
                      ],
                    ),
                    PostCard(
                      post: post,
                      commentSize: 0,
                    )
                  ],
                );
              },
            );
          },
        ));
  }
}
