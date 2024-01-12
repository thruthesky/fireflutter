import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

/// Display user name
///
///
/// Use [UserDisplayName.sync] to rebuild when the name changes.
class UserDisplayName extends StatelessWidget {
  const UserDisplayName({
    super.key,
    required this.uid,
    this.defaultName = 'NoName',
    this.style,
  });

  final String uid;
  final String defaultName;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return UserDoc(
      uid: uid,
      field: Field.displayName,
      builder: (data) => Text(
        data ?? defaultName,
        style: style ?? TextStyle(fontSize: 10, color: Colors.grey.shade600),
      ),
    );
  }
}
