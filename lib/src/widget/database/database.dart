import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

/// Database
///
/// Rebuild the widget when the node is changed.
///
/// [path] is the path of the node.
///
/// [builder] is the widget builder.
///
/// [onWaiting] is the widget to show when waiting for the data.
///
/// Example: below will get the snapshot of /path/to/node
///
/// ```dart
/// Database(path: 'path/to/node', builder: (value) {
///  return Text(value);
/// });
///
class Database extends StatelessWidget {
  const Database({
    super.key,
    required this.path,
    required this.builder,
    this.onWaiting,
  });

  final String path;
  final Widget Function(dynamic value, String path) builder;
  final Widget? onWaiting;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseDatabase.instance.ref(path).onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> event) {
        if (event.connectionState == ConnectionState.waiting) {
          return onWaiting ?? const SizedBox.shrink();
        }
        if (event.hasError) {
          return Text('Error; ${event.error}');
        }
        if (event.hasData && event.data!.snapshot.exists) {
          return builder(event.data!.snapshot.value, path);
        } else {
          return builder(null, path);
        }
      },
    );
  }
}
