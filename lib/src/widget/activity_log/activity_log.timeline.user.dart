import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/widget/activity_log/activity_log.list_view.item.dart';
import 'package:flutter/material.dart';

class ActivityLogTimeLineUser extends StatelessWidget {
  const ActivityLogTimeLineUser({super.key, required this.activity});

  final ActivityLog activity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: UserDoc(
        uid: activity.uid,
        onLoading: const SizedBox(height: 120),
        builder: (actor) {
          if (activity.otherUid != null && activity.otherUid!.isNotEmpty) {
            return UserDoc(
              uid: activity.otherUid!,
              onLoading: const SizedBox(height: 120),
              builder: (target) {
                return ActivityLogListTiLeItem(
                  key: Key(activity.id),
                  activity: activity,
                  actor: actor,
                  message: switch (activity.action) {
                    'like' => tr.likedUserLog.replace({
                        '#a': actor.getDisplayName,
                        '#b': target.getDisplayName,
                      }),
                    'unlike' => tr.unlikedUserLog.replace({
                        '#a': actor.getDisplayName,
                        '#b': target.getDisplayName,
                      }),
                    'follow' => tr.followedUserLog.replace({
                        '#a': actor.getDisplayName,
                        '#b': target.getDisplayName,
                      }),
                    'unfollow' => tr.unfollowedUserLog.replace({
                        '#a': actor.getDisplayName,
                        '#b': target.getDisplayName,
                      }),
                    'viewProfile' => tr.viewProfileUserLog.replace({
                        '#a': actor.getDisplayName,
                        '#b': target.getDisplayName,
                      }),
                    _ => '${actor.getDisplayName} ${activity.type} ${activity.action}',
                  },
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Divider(),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: UserAvatar(
                        user: target,
                        size: 52,
                      ),
                      title: Text(target.getDisplayName),
                      onTap: () {
                        UserService.instance.showPublicProfileScreen(context: context, user: target);
                      },
                    )
                  ],
                );
              },
            );
          }

          return ActivityLogListTiLeItem(
            activity: activity,
            actor: actor,
            message: switch (activity.action) {
              'startApp' => tr.startAppLog.replace({'#a': actor.getDisplayName}),
              'signin' => tr.signinLog.replace({'#a': actor.getDisplayName}),
              'signout' => tr.signoutLog.replace({'#a': actor.getDisplayName}),
              'resign' => tr.resignLog.replace({'#a': actor.getDisplayName}),
              'create' => tr.createUserLog.replace({'#a': actor.getDisplayName}),
              'update' => tr.updateUserLog.replace({'#a': actor.getDisplayName}),
              _ => '${actor.getDisplayName} ${activity.type} ${activity.action}',
            },
          );
        },
      ),
    );
  }
}
