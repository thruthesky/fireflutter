import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class BlockListView extends StatelessWidget {
  const BlockListView({
    super.key,
    this.padding,
    this.separatorBuilder,
  });

  final EdgeInsets? padding;
  final Widget Function(BuildContext, int)? separatorBuilder;

  @override
  Widget build(BuildContext context) {
    return MyDoc(
      builder: (my) => my?.blocks == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(T.noBlockUser.tr),
                  const SizedBox(height: 20),
                  Text(T.youCanBlockUserFromTheirProfilePage.tr),
                  const SizedBox(height: 20),
                  const Icon(
                    Icons.block,
                    size: 100,
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: padding ?? const EdgeInsets.all(8),
              itemBuilder: (_, i) {
                final blockedUid = my.blocks![i];
                return UserDoc(
                  uid: blockedUid,
                  onLoading: const SizedBox.shrink(),
                  builder: (user) {
                    return ListTile(
                      title: Text(user.displayName),
                      // subtitle: Text(user.uid),
                      leading: Avatar(photoUrl: user.photoUrl.orAnonymousUrl),
                      trailing: IconButton(
                        key: Key('blockListTileDeleteBtn${user.uid}'),
                        onPressed: () {
                          UserService.instance
                              .block(context: context, otherUserUid: user.uid);
                        },
                        icon: const Icon(Icons.delete),
                      ),
                    );
                  },
                );
              },
              separatorBuilder: (_, __) =>
                  separatorBuilder?.call(_, __) ?? const Divider(),
              itemCount: my!.blocks!.length,
            ),
    );
  }
}
