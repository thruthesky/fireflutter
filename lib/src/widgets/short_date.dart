import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Returns short date time.
/// By default it returns;
///   - 7:26 pm
///   - 6/27/2022
/// If shorter is set to true, it returns;
///   - 19:26
///   - 6/27
///
class ShortDate extends StatelessWidget {
  const ShortDate(
    this.timestamp, {
    this.style,
    this.padding = const EdgeInsets.all(0),
    this.shorter = false,
    Key? key,
  }) : super(key: key);

  final int timestamp;
  final TextStyle? style;
  final EdgeInsets padding;
  final shorter;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

    final today = DateTime.now();

    // print(
    //     'date; ${date.year} == today.year && ${date.month} == today.month && ${date.day} == today.day');
    bool re;
    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      re = true;
    } else {
      re = false;
    }

    return Padding(
      padding: padding,
      child: Text(
        re
            ? (shorter
                ? DateFormat.Hm().format(date)
                : DateFormat.jm().format(date).toLowerCase())
            : (shorter
                ? DateFormat.Md().format(date)
                : DateFormat.yMd().format(date)),
        style: style,
      ),
    );
  }
}
