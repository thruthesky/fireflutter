import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ChatAvatar extends StatelessWidget {
  const ChatAvatar({
    super.key,
    required this.uid,
    this.padding = const EdgeInsets.only(top: 8.0),
    // TODO customizable
  });

  final String uid;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final userIsCached = UserService.instance.isUserCached(uid);
    if (userIsCached) {
      final cachedUser = UserService.instance.getCache(uid);
      return Row(
        children: [
          cachedUser!.photoUrl.isEmpty
              ? const SizedBox() // TODO empty avatar instead of SizedBox because it may cause rendering problems in the future due to height diff
              : Padding(
                  padding: padding,
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(cachedUser.photoUrl),
                  ),
                ),
        ],
      );
    }
    final user = UserService.instance.get(uid);
    return FutureBuilder(
      future: user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: padding,
            child: const CircleAvatar(
              backgroundColor: Colors.black26,
            ),
          );
        }
        if (snapshot.hasData == false) {
          return Padding(
            // TODO avatar for error no user
            padding: padding,
            child: const CircleAvatar(
              backgroundColor: Colors.black26,
            ),
          );
        }
        final user = snapshot.data as User;
        return Row(
          children: [
            user.photoUrl.isEmpty
                ? const SizedBox() // TODO empty avatar instead of SizedBox because it may cause rendering problems in the future due to height diff
                : Padding(
                    padding: padding,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(user.photoUrl),
                    ),
                  ),
          ],
        );
      },
    );
  }
}
