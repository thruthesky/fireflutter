import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// Display login first message.
class LoginFirst extends StatelessWidget {
  const LoginFirst({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return loggedIn
        ? const SizedBox.shrink()
        : const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Please login to use the full functionality of this app.',
            ),
          );
  }
}
