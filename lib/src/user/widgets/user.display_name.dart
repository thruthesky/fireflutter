import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

/// Display user name
///
/// You can provide one of [uid] or [user].
///
/// [uid] is required if [user] is not provided.
///
/// If [user] is provided and [initialData] is not provided, [user.displayName]
/// is used as default data.
///
/// [initialData] is used if [user] is not provided. Use this to reduce the
/// flickering.
///
/// [style] is used to style the text.
///
/// [cacheId] is used to cache the data.
/// 캐시를 하면, 화면이 깜빡임이 훨씬 덜 하다.
class UserDisplayName extends StatelessWidget {
  const UserDisplayName({
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
            initialData: initialData ?? user?.displayName,
            field: Field.displayName,
            builder: (t) => builder(t, context),
          )
        : UserDoc.field(
            cacheId: cacheId,
            uid: uid ?? user!.uid,
            initialData: initialData ?? user?.displayName,
            field: Field.displayName,
            builder: (t) => builder(t, context),
          );
  }

  const UserDisplayName.sync({
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
          cacheId: 'user_display_name_$uid',
          sync: true,
        );

  Widget builder(data, BuildContext context) => Text(
        data ?? initialData ?? '',
        style: style ?? Theme.of(context).textTheme.bodyMedium,
      );
}
