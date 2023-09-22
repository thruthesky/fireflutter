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
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              tr.loginFirstToUseCompleteFunctionality,
              style: TextStyle(color: Theme.of(context).colorScheme.onSecondary.withAlpha(120)),
            ),
          );
  }
}
