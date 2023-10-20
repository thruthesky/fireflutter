import 'package:fireflutter/src/model/activity_log/activity_log.dart';
import 'package:fireflutter/src/model/activity_log/activity_log.type.dart';
import 'package:fireflutter/src/widgets.dart';
import 'package:flutter/material.dart';

class ActivityLogTimeLine extends StatelessWidget {
  const ActivityLogTimeLine({super.key, required this.activity});

  final ActivityLog activity;

  @override
  Widget build(BuildContext context) {
    if (activity.type == Log.type.user) {
      return ActivityLogTimeLineUser(key: key, activity: activity);
      // } else if( activity.type == Log.type.post) {
      //   return ActivityLogTimeLinePost(activity: activity);
      // } else if (activity.type == Log.type.comment) {
      //   return ActivityLogTimeLineComment(activity: activity);
    } else {
      return const SizedBox.shrink(); //Text('Unknown acitivyt');
      // return ActivityLogTimeLineUnknown(activity: activity);
    }
  }
}


///
///
///