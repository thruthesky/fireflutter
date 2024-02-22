import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class BlockListView extends StatelessWidget {
  const BlockListView({super.key});

  @override
  Widget build(BuildContext context) {
    return MyDoc(
      builder: (my) => my?.blocks == null
          ? const Column(
              children: [
                Text('No blocked users'),
                SizedBox(height: 20),
                Text('You can block users from their profile page'),
                SizedBox(height: 20),
                Icon(
                  Icons.block,
                  size: 100,
                ),
              ],
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
