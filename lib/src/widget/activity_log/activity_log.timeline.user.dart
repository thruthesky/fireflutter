import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/model/activity_log/activity_log.dart';
import 'package:fireflutter/src/model/activity_log/activity_log.type.dart';
import 'package:flutter/material.dart';

class ActivityLogTimeLineUser extends StatelessWidget {
  const ActivityLogTimeLineUser({super.key, required this.activity});

  final ActivityLog activity;

  @override
  Widget build(BuildContext context) {
    // if (ActivityLogService.instance.customize.activityLogTimelineUserBuilder != null) {
    //   return ActivityLogService.instance.customize.activityLogTimelineUserBuilder!.call(activity);
    // }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: UserDoc(
        uid: activity.uid,
        onLoading: const SizedBox.shrink(),
        builder: (actor) {
          if ([
            Log.user.startApp,
            Log.user.signin,
            Log.user.signout,
            Log.user.resign,
            Log.user.create,
            Log.user.update,
          ].contains(activity.action)) {
            return Row(
              children: [
                UserAvatar(user: actor),
                Text(tr.startAppLog.replace({'#a': actor.getDisplayName})
                    // (activity.action == Log.user.startApp) ?
                    // tr.startAppLog.replace({'#a': actor.getDisplayName}) :
                    // (activity.action == Log.user.signin) ?
                    // tr.signinLog.replace({'#a': actor.getDisplayName}) :
                    // (activity.action == Log.user.signout) ?
                    // tr.signoutLog.replace({'#a': actor.getDisplayName}) :
                    // (activity.action == Log.user.resign) ?
                    // tr.resignLog.replace({'#a': actor.getDisplayName}) :
                    // (activity.action == Log.user.create) ?
                    // tr.createUserLog.replace({'#a': actor.getDisplayName}) :
                    // (activity.action == Log.user.update) ?
                    // tr.updateUserLog.replace({'#a': actor.getDisplayName}) : ''
                    ),
              ],
            );
          }

          if ([
            Log.user.like,
            Log.user.unlike,
            Log.user.follow,
            Log.user.unfollow,
            Log.user.viewProfile,
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
