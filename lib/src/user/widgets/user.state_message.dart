import 'package:fireflutter/fireflutter.dart';
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
    this.sync = false,
  }) : assert(uid != null || user != null);

  final String? uid;
  final UserModel? user;
  final String? initialData;
  final TextStyle? style;
  final String? cacheId;
  final bool sync;

  @override
  Widget build(BuildContext context) {
    return sync
        ? UserDoc.fieldSync(
            uid: uid ?? user!.uid,
            initialData: initialData ?? user?.stateMessage,
            field: Field.stateMessage,
            builder: builder,
          )
        : UserDoc.field(
            cacheId: cacheId,
            uid: uid ?? user!.uid,
            initialData: initialData ?? user?.stateMessage,
            field: Field.stateMessage,
            builder: builder,
          );
  }

  Widget builder(data) => Text(
        (data ?? initialData ?? '').toString().cut(50),
        style: style ??
            const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );

  /// Realtime update the user's state message.
  const UserStateMessage.sync({
    Key? key,
    String? uid,
    UserModel? user,
    String? initialData,
    TextStyle? style,
  }) : this(
          key: key,
          uid: uid,
          user: user,
          initialData: initialData,
          style: style,
          sync: true,
        );
}
