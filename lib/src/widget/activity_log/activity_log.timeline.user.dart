import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ActivityLogTimeLineUser extends StatelessWidget {
  const ActivityLogTimeLineUser({super.key, required this.activity});

  final ActivityLog activity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: UserDoc(
        uid: activity.uid,
        onLoading: const SizedBox.shrink(),
        builder: (actor) {
          if ([
            Log.user.like,
            Log.user.unlike,
            Log.user.follow,
            Log.user.unfollow,
            Log.user.viewProfile,
          ].contains(activity.action)) {
            return Text('Actor name; ${actor.getDisplayName}');
            // return UserDoc(
            //   uid: activity.otherUid,
            //   builder: (target) {
            //     return ActivityLogListTiLeItem(
            //       key: Key(activity.id),
            //       activity: activity,
            //       actor: actor,
            //       message: switch (activity.action) {
            //         'like' => tr.likedUserLog.replace({
            //             '#a': actor.getDisplayName,
            //             '#b': target.getDisplayName,
            //           }),
            //         'unlike' => tr.unlikedUserLog.replace({
            //             '#a': actor.getDisplayName,
            //             '#b': target.getDisplayName,
            //           }),
            //         'follow' => tr.followedUserLog.replace({
            //             '#a': actor.getDisplayName,
            //             '#b': target.getDisplayName,
            //           }),
            //         'unfollow' => tr.unfollowedUserLog.replace({
            //             '#a': actor.getDisplayName,
            //             '#b': target.getDisplayName,
            //           }),
            //         'viewProfile' => tr.viewProfileUserLog.replace({
            //             '#a': actor.getDisplayName,
            //             '#b': target.getDisplayName,
            //           }),
            //         _ => '${actor.getDisplayName} ${activity.type} ${activity.action}',
            //       },
            //       children: [
            //         const Padding(
            //           padding: EdgeInsets.symmetric(vertical: 16.0),
            //           child: Divider(),
            //         ),
            //         ListTile(
            //           visualDensity: VisualDensity.compact,
            //           leading: UserAvatar(
            //             user: target,
            //             size: 52,
            //           ),
            //           title: Text(target.getDisplayName),
            //           onTap: () {
            //             UserService.instance.showPublicProfileScreen(context: context, user: target);
            //           },
            //         )
            //       ],
            //     );
            //   },
            // );
          }

          return const Text('Single user');

          // if ([
          //   Log.user.startApp,
          //   Log.user.signin,
          //   Log.user.signout,
          //   Log.user.resign,
          //   Log.user.create,
          //   Log.user.update,
          // ].contains(activity.action)) {
          //   return ActivityLogListTiLeItem(
          //     activity: activity,
          //     actor: actor,
          //     message: switch (activity.action) {
          //       'startApp' => tr.startAppLog.replace({'#a': actor.getDisplayName}),
          //       'signin' => tr.signinLog.replace({'#a': actor.getDisplayName}),
          //       'signout' => tr.signoutLog.replace({'#a': actor.getDisplayName}),
          //       'resign' => tr.resignLog.replace({'#a': actor.getDisplayName}),
          //       'create' => tr.createUserLog.replace({'#a': actor.getDisplayName}),
          //       'update' => tr.updateUserLog.replace({'#a': actor.getDisplayName}),
          //       _ => '${actor.getDisplayName} ${activity.type} ${activity.action}',
          //     },
          //   );
          // },
        },
      ),
    );
  }
}
