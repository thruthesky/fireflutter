import 'package:fireflutter/src/model/activity_log/activity_log.dart';
import 'package:flutter/material.dart';

class ActivityLogCustomize {
  Widget Function(ActivityLog activity)? timelineBuilder;
  Widget Function(ActivityLog activity)? userTimelineBuilder;
  Widget Function(ActivityLog activity)? postTimelineBuilder;
  Widget Function(ActivityLog activity)? commentTimelineBuilder;

  ActivityLogCustomize({
    this.timelineBuilder,
    this.userTimelineBuilder,
    this.postTimelineBuilder,
    this.commentTimelineBuilder,
  });
}
