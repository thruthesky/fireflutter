import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/model/activity_log/activity_log.dart';
import 'package:fireflutter/src/model/activity_log/activity_log.type.dart';
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
                return Column(
                  children: [
                    Row(
                      children: [
                        UserAvatar(user: actor),
                        const SizedBox(width: 8),
                        if (activity.action == Log.post.create)
                          Text(tr.createPostLog.replace({
                            '#a': actor.getDisplayName,
                          })),
                        if (activity.action == Log.post.update)
                          Text(tr.updatePostLog.replace({
                            '#a': actor.getDisplayName,
                          })),
                        if (activity.action == Log.post.delete)
                          Text(tr.deletePostLog.replace({
                            '#a': actor.getDisplayName,
                          })),
                        if (activity.action == Log.post.like)
                          Text(tr.likedPostLog.replace({
                            '#a': actor.getDisplayName,
                          })),
                        if (activity.action == Log.post.unlike)
                          Text(tr.unlikedPostLog.replace({
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
          }),
    );
  }
}
