import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// UserDoc
///
/// Build a widget with a user model.
class UserDoc extends StatelessWidget {
  const UserDoc({
    super.key,
    required this.uid,
    required this.builder,
    this.onLoading,
  });
  final String uid;
  final Widget Function(User) builder;
  final Widget? onLoading;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: UserService.instance.get(uid),
      builder: buildStreamWidget,
    );
  }

  Widget buildStreamWidget(BuildContext _, AsyncSnapshot<User?> snapshot) {
    /// While loading user data
    if (snapshot.connectionState == ConnectionState.waiting) {
      /// If there is a cached user data, use it.
      if (UserService.instance.userCache.containsKey(uid)) {
        return builder(UserService.instance.userCache[uid]!);
      } else {
        /// If there is no cached user data, then, show the loading widget.
        return onLoading ?? const SizedBox.shrink();
      }
    }

    /// If it can't load user data, (or there is no user document)
    if (snapshot.data == null) {
      ///
      /// It passes the user model with the current time when there is no user document.
      return builder(User.nonExistent());
    }
    return builder(snapshot.data as User);
  }
}
