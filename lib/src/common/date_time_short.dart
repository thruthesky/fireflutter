import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class DateTimeShort extends StatelessWidget {
  const DateTimeShort({
    super.key,
    this.stamp,
    this.dateTime,
  });

  final int? stamp;
  final DateTime? dateTime;

  @override
  Widget build(BuildContext context) {
    return Text(
      dateTimeShort(
        stamp != null ? DateTime.fromMillisecondsSinceEpoch(stamp!) : dateTime!,
      ),
      style: Theme.of(context).textTheme.labelSmall,
    );
  }
}
