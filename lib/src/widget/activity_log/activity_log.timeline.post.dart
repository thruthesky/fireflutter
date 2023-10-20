import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/model/activity_log/activity_log.dart';
import 'package:fireflutter/src/model/activity_log/activity_log.type.dart';
import 'package:flutter/material.dart';

class ActivityLogTimeLinePost extends StatelessWidget {
  const ActivityLogTimeLinePost({super.key, required this.activity});

  final ActivityLog activity;

  ActivityLogPostAction get logPostAction => Log.post;

  @override
  Widget build(BuildContext context) {
    // if (ActivityLogService.instance.customize.activityLogTimelinePostBuilder != null) {
    //   return ActivityLogService.instance.customize.activityLogTimelinePostBuilder!.call(activity);
    // }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: UserDoc(
        uid: activity.uid,
        onLoading: const SizedBox.shrink(),
        builder: (actor) {
          if ([
            logPostAction.create,
            logPostAction.update,
            logPostAction.delete,
          ].contains(activity.action)) {
            return Row(
              children: [
                UserAvatar(user: actor),
                Text(
                  tr.startAppLog.replace(
                    {
                      '#a': actor.getDisplayName,
                    },
                  ),
                ),
              ],
            );
          }

          if ([
            logPostAction.like,
            logPostAction.unlike,
          ].contains(activity.action)) {
            return UserDoc(
              uid: activity.otherUid,
              onLoading: const SizedBox.shrink(),
              builder: (target) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        UserAvatar(user: actor),
                        const Text(' -> '),
                        UserAvatar(user: target),
                      ],
                    ),
                    Text(
                      tr.whoFollowedWho.replace(
                        {
                          '#a': actor.getDisplayName,
                          '#b': target.getDisplayName,
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          }

          return Row(
            children: [
              UserAvatar(user: actor),
              Text('${actor.getDisplayName} ${activity.action}'),
            ],
          );
        },
      ),
    );
  }
}
