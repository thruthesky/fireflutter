import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TimestampText extends StatelessWidget {
  const TimestampText({
    super.key,
    required this.timestamp,
    this.builder,
  });

  final Timestamp timestamp;
  final Function(Timestamp timestamp)? builder;

  @override
  Widget build(BuildContext context) {
    FeedService.instance.getAllByMinusDate();
    if (builder != null) return builder!(timestamp);
    return Text(
      _toAgoDate(timestamp),
      style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black45),
    );
  }

  _toAgoDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    Duration diff = DateTime.now().difference(date);
    if (diff.inDays >= 2) {
      return date.toIso8601String();
    } else if (diff.inDays >= 1) {
      return '${diff.inDays} ${diff.inDays == 1 ? "day" : "days"} ago';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours} ${diff.inHours == 1 ? "hour" : "hours"} ago';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes} ${diff.inMinutes == 1 ? "minute" : "minutes"} ago';
    } else if (diff.inSeconds >= 1) {
      return '${diff.inSeconds} ${diff.inSeconds == 1 ? "second" : "seconds"} ago';
    } else {
      return 'Just Now';
    }
  }
}
