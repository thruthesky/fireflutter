import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// Database count no of keys
///
/// This is a widget that counts the number of keys in a node. Basically, it
/// just works like [Database] widget, but it returns the number of keys in the
/// node. Use this widget to build a child widget depending on the no of kes
/// in the node.
///
/// [path] is the path of the node.
///
/// [builder] is the widget builder.
class DatabaseCount extends StatelessWidget {
  const DatabaseCount({
    super.key,
    required this.path,
    required this.builder,
  });

  final String path;
  final Widget Function(int value) builder;

  @override
  Widget build(BuildContext context) {
    return Database(
      path: path,
      onWaiting: builder(0),
      builder: (value) {
        if (value == null) {
          return builder(0);
        }
        if (value is Map) {
          return builder(value.keys.length);
        }
        return builder(0);
      },
    );
  }
}
