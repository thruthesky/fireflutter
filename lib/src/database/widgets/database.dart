import 'package:fireship/src/database/widgets/value.dart';
import 'package:flutter/material.dart';

/// Database
///
/// Rebuild the widget when the node is changed.
///
/// [path] is the path of the node.
///
/// [builder] is the widget builder.
///
/// [onLoading] is the widget to show when waiting for the data.
///
/// Example: below will get the snapshot of /path/to/node
///
/// ```dart
/// Database(path: 'path/to/node', builder: (value) {
///  return Text(value);
/// });
///
@Deprecated('Use Value instead')
class Database extends StatelessWidget {
  const Database({
    super.key,
    required this.path,
    required this.builder,
    this.onLoading,
  });

  final String path;

  /// [dynamic] is the value of the node.
  /// [String] is the path of the node.
  final Widget Function(dynamic value) builder;
  final Widget? onLoading;

  @override
  Widget build(BuildContext context) {
    /// To prevent the widget from rebuilding when the data is loaded.
    /// It reduces the flickering.
    return Value(
      path: path,
      builder: builder,
      onLoading: onLoading,
    );
  }

  /// 한번만 가져온다. 단, 위젯이 다시 생성되면 다시 가져온다.
  static Widget once({
    required String path,
    required Widget Function(dynamic value) builder,
    Widget? onLoading,
  }) {
    return Value.once(
      path: path,
      builder: builder,
      onLoading: onLoading,
    );
  }
}
