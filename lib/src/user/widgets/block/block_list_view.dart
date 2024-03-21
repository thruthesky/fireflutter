import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class BlockListView extends StatelessWidget {
  const BlockListView({super.key});

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
              itemBuilder: (_, i) {
                final blockedUid = my.blocks![i];
                return UserDoc(
                  uid: blockedUid,
                  onLoading: const ListTile(
                    leading: Avatar(photoUrl: anonymousUrl),
                    title: Text('Loading...'),
                    subtitle: Text('...'),
                    trailing:
                        IconButton(onPressed: null, icon: Icon(Icons.delete)),
                  ),
                  builder: (user) {
                    return ListTile(
                      title: Text(user.displayName),
                      subtitle: Text(user.uid),
                      leading: Avatar(photoUrl: user.photoUrl.orAnonymousUrl),
                      trailing: IconButton(
                        key: Key('blockListTileDeleteBtn${user.uid}'),
                        onPressed: () {
                          my.block(user.uid);
                        },
                        icon: const Icon(Icons.delete),
                      ),
                    );
                  },
                );
              },
              separatorBuilder: (_, __) => const Divider(),
              itemCount: my!.blocks!.length,
            ),
    );
  }
}
