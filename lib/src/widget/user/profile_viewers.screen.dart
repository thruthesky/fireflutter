import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ProfileViewersListScreen extends StatelessWidget {
  const ProfileViewersListScreen({
    super.key,
    this.itemBuilder,
  });

  final Widget Function(User)? itemBuilder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Viewers List'),
      ),
      body: FirestoreListView(
        query: profileViewHistoryCol.where('uid', isEqualTo: myUid).orderBy('lastViewdAt', descending: true),
        itemBuilder: (context, doc) {
          final viewer = Viewer.fromDocumentSnapshot(doc);
          return UserDoc(
            uid: viewer.seenBy,
            builder: (user) {
              return itemBuilder?.call(user) ??
                  ListTile(
                    onTap: () => UserService.instance.showPublicProfileScreen(context: context, user: user),
                    leading: UserAvatar(
                      user: user,
                    ),
                    title: Text(user.name),
                    trailing: const Icon(Icons.arrow_forward_ios),
                  );
            },
          );
        },
        errorBuilder: (context, error, stackTrace) => Text('Error; ${error.toString()}'),
      ),
    );
  }
}
