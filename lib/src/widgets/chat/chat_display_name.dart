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
    /// Blinking problem.
    return FutureBuilder(
      future: UserService.instance.get(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        if (snapshot.hasData == false) return const SizedBox.shrink();
        final user = snapshot.data as User;
        return user.displayName.isEmpty == true
            ? const SizedBox.shrink()
            : Text(
                user.displayName,
                style: textStyle,
              );
      },
    );
  }
}
