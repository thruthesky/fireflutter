import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

enum DateTimeTextType {
  /// just now, 1 hour ago / 1 day ago / 1 week ago / 1 month ago / 1 year ago
  ago,

  /// 2023-03-03 or 00:00
  short,

  /// now, 1s, 3s, 1d, 3Mo, 1y
  abbreviated,
}

/// Convert DateTime to a readable text
///
class DateTimeText extends StatelessWidget {
  const DateTimeText({
    super.key,
    required this.dateTime,
    this.type = DateTimeTextType.ago,
    this.locale,
    this.style,
  });

  final DateTime dateTime;
  final DateTimeTextType type;
  final TextStyle? style;
  final String? locale;

  @override
  Widget build(BuildContext context) {
    return Text(
      switch (type) {
        DateTimeTextType.short => dateTimeShort(dateTime),
        DateTimeTextType.abbreviated => dateTimeAbbreviated(dateTime),
        _ => dateTimeAgo(dateTime, locale: locale),
      },
      style: style ?? const TextStyle(fontWeight: FontWeight.w500, color: Colors.black45),
    );
  }
}
