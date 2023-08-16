import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ChatDisplayName extends StatelessWidget {
  const ChatDisplayName({
    super.key,
    required this.uid,
    this.textStyle = const TextStyle(fontWeight: FontWeight.bold),
  });

  final String uid;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    final userIsCached = UserService.instance.isUserCached(uid);
    if (userIsCached) {
      final cachedUser = UserService.instance.getCache(uid);
      return cachedUser!.displayName.isEmpty == true
          ? const SizedBox()
          : Text(
              cachedUser.displayName,
              style: textStyle,
            );
    }
    final user = UserService.instance.get(uid);
    return FutureBuilder(
      future: user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox();
        if (snapshot.hasData == false) return const SizedBox();
        final user = snapshot.data as User;
        return user.displayName.isEmpty == true
            ? const SizedBox()
            : Text(
                user.displayName,
                style: textStyle,
              );
      },
    );
  }
}
