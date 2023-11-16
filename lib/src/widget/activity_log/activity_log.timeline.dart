import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ActivityLogTimeLine extends StatelessWidget {
  const ActivityLogTimeLine({super.key, required this.activity});

  final ActivityLog activity;

  ActivityLogCustomize get customize => ActivityLogService.instance.customize;

  bool get hasTimeLineBuilder => customize.timelineBuilder != null;
  bool get isCustomLogType =>
      ActivityLogService.instance.activityLogTypes.contains(activity.type);

  @override
  Widget build(BuildContext context) {
    if (activity.type == Log.type.user) {
      return customize.userTimelineBuilder?.call(activity) ??
          ActivityLogTimeLineUser(activity: activity);
    } else if (activity.type == Log.type.post) {
      return customize.postTimelineBuilder?.call(activity) ??
          ActivityLogTimeLinePost(activity: activity);
    } else if (activity.type == Log.type.comment) {
      return customize.commentTimelineBuilder?.call(activity) ??
          ActivityLogTimeLineComment(activity: activity);
    } else if (hasTimeLineBuilder && isCustomLogType) {
      return customize.timelineBuilder!.call(activity);
    }

    return UserDoc(
      uid: activity.uid,
      onLoading: const SizedBox(height: 100),
      builder: (actor) {
        return ActivityLogListTiLeItem(
          activity: activity,
          actor: actor,
          message:
              'Unknown ActivityLogType: ${activity.type} ${activity.action}',
        );
      },
    );
  }
}
