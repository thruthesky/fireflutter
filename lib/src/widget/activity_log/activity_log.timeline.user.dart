import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/model/activity_log/activity_log.dart';
import 'package:fireflutter/src/model/activity_log/activity_log.type.dart';
import 'package:flutter/material.dart';

class ActivityLogTimeLineUser extends StatelessWidget {
  const ActivityLogTimeLineUser({super.key, required this.activity});

  final ActivityLog activity;

  String getMessage(User actor, [User? target]) {
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

  Widget displayTile({required Widget child}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 64,
          child: Column(
            children: [
              activityIcon,
              Text(
                dateTimeAgo(activity.createdAt),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            margin: EdgeInsets.zero,
            color: Colors.grey[100],
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Padding(padding: const EdgeInsets.all(16.0), child: child),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
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
            return displayTile(
              child: Row(
                children: [
                  UserAvatar(
                    user: actor,
                    size: 52,
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: Text(getMessage(actor))),
                ],
              ),
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
                return displayTile(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          UserAvatar(
                            user: actor,
                            size: 52,
                          ),
                          const SizedBox(width: 16),
                          Expanded(child: Text(getMessage(actor, target))),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Divider(),
                      ),
                      ListTile(
                        visualDensity: VisualDensity.compact,
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
                  ),
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

  Widget get activityIcon => Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: Colors.lightBlue[300]!,
            width: 1,
          ),
        ),
        child: Icon(
          switch (activity.action) {
            'startApp' => Icons.home,
            'signin' => Icons.login,
            'signout' => Icons.logout,
            'resign' => Icons.delete,
            'create' => Icons.add,
            'update' => Icons.update,
            'like' => Icons.thumb_up,
            'unlike' => Icons.thumb_down,
            'follow' => Icons.add,
            'unfollow' => Icons.remove,
            'viewProfile' => Icons.person,
            _ => Icons.error,
          },
        ),
      );
}
