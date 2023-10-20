import 'package:fireflutter/src/model/activity_log/activity_log.dart';
import 'package:flutter/material.dart';

class ActivityLogCustomize {
  Widget Function(ActivityLog activityLog)? activityLogTimelineUserBuilder;

  ActivityLogCustomize({
    this.activityLogTimelineUserBuilder,
  });
}
