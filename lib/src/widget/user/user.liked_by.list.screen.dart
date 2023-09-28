import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// User like list screen
///
/// This screen shows a list of users who liked a post, comment, or a profile.
///
/// Use this screen to show a user list and when it is tapped, show public profile.
class UserLikedByListScreen extends StatelessWidget {
  static const String routeName = '/UserLikeList';
  const UserLikedByListScreen({super.key, required this.uids});

  final List<String> uids;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr.like),
      ),
      body: ListView(
        children: uids
            .map(
              (id) => FutureBuilder(
                future: User.getFromDatabaseSync(id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator.adaptive();
                  }
                  if (snapshot.hasError) {
                    return Text('Error; ${snapshot.error.toString()}');
                  }
                  final user = snapshot.data as User;
                  return ListTile(
                    leading: UserAvatar(user: user),
                    title: Text(user.displayName.isEmpty ? user.name : user.displayName),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => UserService.instance.showPublicProfileScreen(
                      context: context,
                      user: user,
                    ),
                  );
                },
              ),
            )
            .toList(),
      ),
    );
  }
}
