import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

/// Display user state message
///
/// [uid] is required if [user] is not provided.
///
/// [user] is required if [uid] is not provided.
///
/// [initialData] is used if [user] is not provided. Use this to reduce the
/// flickering.
///
/// [style] is used to style the text.
///
/// [cacheId] is used to cache the data.
class UserStateMessage extends StatelessWidget {
  const UserStateMessage({
    super.key,
    this.uid,
    this.user,
    this.initialData,
    this.style,
    this.cacheId,
  }) : assert(uid != null || user != null);

  final String? uid;
  final UserModel? user;
  final String? initialData;
  final TextStyle? style;
  final String? cacheId;

  @override
  Widget build(BuildContext context) {
    return UserDoc.field(
      cacheId: cacheId,
      uid: uid ?? user!.uid,
      initialData: initialData ?? user?.stateMessage,
      field: Field.stateMessage,
      builder: (data) => Text(
        data ?? initialData ?? '',
        style: style ?? TextStyle(fontSize: 10, color: Colors.grey.shade600),
      ),
    );
  }
}
