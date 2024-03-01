import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// A widget that displays the user's background image.
///
/// [user] 가 지정되면, 해당 사용자의 background image 를 표시한다. 이 때, background image 가 없으면
/// [initialData] 를 사용한다.
///
/// [uid] 가 지정되고, [user] 가 지정되지 않으면, [initialData] 를 사용하여 먼저 background image 를
/// 표시하고, 그 다음에 DB 에서 가져와 이미지를 표시한다.
class UserBackgroundImage extends StatelessWidget {
  const UserBackgroundImage({
    super.key,
    this.uid,
    this.user,
    this.initialData,
    this.sync = false,
  });

  final String? uid;
  final UserModel? user;
  final String? initialData;
  final bool sync;

  @override
  Widget build(BuildContext context) {
    final v = initialData ??
        user?.profileBackgroundImageUrl
            .or('https://picsum.photos/id/171/400/900');

    return sync
        ? UserDoc.fieldSync(
            uid: uid ?? user!.uid,
            initialData: v,
            field: Field.profileBackgroundImageUrl,
            builder: builder,
          )
        : UserDoc.field(
            uid: uid ?? user!.uid,
            initialData: v,
            field: Field.profileBackgroundImageUrl,
            builder: builder,
          );
  }

  Widget builder(url) => CachedNetworkImage(
        imageUrl: url ?? initialData ?? 'https://picsum.photos/id/171/400/900',
        fit: BoxFit.cover,
      );

  /// Realtime update the user's background image.
  const UserBackgroundImage.sync({
    Key? key,
    String? uid,
    UserModel? user,
    String? initialData,
  }) : this(
          key: key,
          uid: uid,
          user: user,
          initialData: initialData,
          sync: true,
        );
}
