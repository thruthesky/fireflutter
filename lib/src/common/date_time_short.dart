import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class DateTimeShort extends StatelessWidget {
  const DateTimeShort({super.key, required this.stamp});

  final int stamp;

  @override
  Widget build(BuildContext context) {
    return Text(
      dateTimeShort(DateTime.fromMillisecondsSinceEpoch(stamp)),
      style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
    );
  }
}
