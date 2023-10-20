import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/model/activity_log/activity_log.dart';
import 'package:flutter/material.dart';

class ActivityLogTimeLineUser extends StatelessWidget {
  const ActivityLogTimeLineUser({super.key, required this.activity});

  final ActivityLog activity;

  @override
  Widget build(BuildContext context) {
    return UserDoc(
      uid: activity.uid,
      builder: (actor) {
        return UserDoc(
          uid: activity.otherUid,
          builder: (target) {
            return Column(
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
                      'a': actor.getDisplayName,
                      'b': target.getDisplayName,
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
