import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

enum DateTimeTextType {
  /// just now, 1 hour ago / 1 day ago / 1 week ago / 1 month ago / 1 year ago
  ago,

  /// 2023-03-03 or 00:00
  short,
}

/// Convert DateTime to a readable text
///
class DateTimeText extends StatelessWidget {
  const DateTimeText({
    super.key,
    required this.dateTime,
    this.type = DateTimeTextType.ago,
    this.style =
        const TextStyle(fontWeight: FontWeight.w500, color: Colors.black45),
  });

  final DateTime dateTime;
  final DateTimeTextType type;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Text(
      switch (type) {
        DateTimeTextType.short => dateTimeAgo(dateTime),
        _ => dateTimeAgo(dateTime),
      },
      style: style,
    );
  }
}
