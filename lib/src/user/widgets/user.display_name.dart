import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

/// Display user name
///
///
/// Use [UserDisplayName.sync] to rebuild when the name changes.
class UserDisplayName extends StatelessWidget {
  const UserDisplayName({super.key, required this.uid, this.defaultName = 'NoName'});

  final String uid;
  final String defaultName;

  @override
  Widget build(BuildContext context) {
    return UserDoc(
      uid: uid,
      field: Field.displayName,
      builder: (data) => Text(
        data ?? defaultName,
        style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
      ),
    );
  }
}
