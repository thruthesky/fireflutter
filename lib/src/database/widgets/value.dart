import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

import 'package:firebase_database/firebase_database.dart';

/// Value
///
/// Rebuild the widget when the node is changed.
///
/// [path] is the path of the node. If the node does not exist, pass null to builder().
/// [path] 는 노드의 경로이다. 만약 해당 노드가 존재하지 않으면 null 을 builder() 로 전달한다.
///
/// [ref] is the reference of the node. If the node does not exist, pass null to builder().
///
/// [builder] is the widget builder.
///
/// [initialData] is the initial data to show when waiting for the data. This
/// is useful to prevent the screen flickering.
///
/// [onLoading] is the widget to show when waiting for the data.
///
/// Example: below will get the snapshot of /path/to/node
///
/// ```dart
/// Value(path: 'path/to/node', builder: (value) {
///  return Text(value);
/// });
///
class Value extends StatelessWidget {
  const Value({
    super.key,
    this.ref,
    required this.builder,
    this.initialData,
    this.onLoading,
  });

  final DatabaseReference? ref;

  final dynamic initialData;

  /// [dynamic] is the value of the node.
  /// [String] is the path of the node.
  final Widget Function(dynamic value) builder;
  final Widget? onLoading;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: ref?.onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> event) {
        if (event.connectionState == ConnectionState.waiting) {
          if (event.hasData) {
            return builder(event.data!.snapshot.value);
          } else if (initialData != null) {
            return builder(initialData);
          }
          return onLoading ?? const SizedBox.shrink();
        }
        if (event.hasError) {
          return Text('Error; path: ${ref?.path}, message: ${event.error}');
        }
        // value may be null.
        return builder(event.data?.snapshot.value);
      },
    );
  }

  /// 한번만 가져온다. 단, 위젯이 다시 생성되면 다시 가져온다.
  ///
  /// [initialData] 를 사용하면 화면 깜빡임을 현저하게 줄일 수 있다.
  ///
  /// [onLoading] 을 사용하면 데이터를 기다리는 동안 보여줄 위젯을 지정할 수 있다.
  ///
  /// [path] 와 [ref] 둘 중 하나는 반드시 있어야 한다.
  static Widget once({
    @Deprecated('Use ref instead of path') String? path,
    DatabaseReference? ref,
    required Widget Function(dynamic value) builder,
    dynamic initialData,
    Widget? onLoading,
  }) {
    if (path == null && ref == null) {
      throw ArgumentError('path or ref must be not null');
    }
    return FutureBuilder(
      future: ref?.once() ?? FirebaseDatabase.instance.ref(path).once(),
      builder: (context, AsyncSnapshot<DatabaseEvent> event) {
        if (event.connectionState == ConnectionState.waiting) {
          if (event.hasData) {
            return builder(event.data!.snapshot.value);
          } else if (initialData != null) {
            return builder(initialData);
          }
          return onLoading ?? const SizedBox.shrink();
        }
        if (event.hasError) {
          dog('---> Value.once() -> Error; path: ${ref?.path ?? path}, message: ${event.error}');
          return Text('Error; ${event.error}');
        }

        return builder(event.data?.snapshot.value);
      },
    );
  }
}
