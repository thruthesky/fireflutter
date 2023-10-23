import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/model/activity_log/activity_log.dart';
import 'package:fireflutter/src/model/activity_log/activity_log.type.dart';
import 'package:flutter/material.dart';

class ActivityLogTimeLineUser extends StatelessWidget {
  const ActivityLogTimeLineUser({super.key, required this.activity});

  final ActivityLog activity;

  String getMessage(ActivityLog activity, User actor, [User? target]) {
    return switch (activity.action) {
      'startApp' => tr.startAppLog.replace({'#a': actor.getDisplayName}),
      'signin' => tr.signinLog.replace({'#a': actor.getDisplayName}),
      'signout' => tr.signoutLog.replace({'#a': actor.getDisplayName}),
      'resign' => tr.resignLog.replace({'#a': actor.getDisplayName}),
      'create' => tr.createUserLog.replace({'#a': actor.getDisplayName}),
      'update' => tr.updateUserLog.replace({'#a': actor.getDisplayName}),
      'like' => tr.likedUserLog.replace({
          '#a': actor.getDisplayName,
          '#b': target!.getDisplayName,
        }),
      'unlike' => tr.unlikedUserLog.replace({
          '#a': actor.getDisplayName,
          '#b': target!.getDisplayName,
        }),
      'follow' => tr.followedUserLog.replace({
          '#a': actor.getDisplayName,
          '#b': target!.getDisplayName,
        }),
      'unfollow' => tr.unfollowedUserLog.replace({
          '#a': actor.getDisplayName,
          '#b': target!.getDisplayName,
        }),
      'viewProfile' => tr.viewProfileUserLog.replace({
          '#a': actor.getDisplayName,
          '#b': target!.getDisplayName,
        }),
      _ => 'actor.getDisplayName $activity.action $activity.type',
    };
  }

  @override
  Widget build(BuildContext context) {
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
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    UserAvatar(user: actor),
                    const SizedBox(width: 8),
                    Text(getMessage(activity, actor)),
                  ],
                ),
                Text(
                  dateTimeAgo(activity.createdAt),
                )
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
                      getMessage(activity, actor, target),
                    ),
                    Text(
                      dateTimeAgo(activity.createdAt),
                    )
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
