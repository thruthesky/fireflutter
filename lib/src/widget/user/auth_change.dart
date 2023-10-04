import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// AuthChange
///
/// Builder widget that returns a firebase [User] object when the
/// [authStateChanges] event fires.
///
/// This is useful for determining if the user is logged in or not from/to the
/// firebase authentication.
/// If the user is logged in, the [User] object will be passwd over the
/// parameter. Or else, null will be passed.
///
/// Example:
/// ```dart
/// AuthChange(builder: (user) {
///   if (user == null) {
///     return const Text('User is not logged in.');
///   }
///   return const Text('User is logged in.');
/// }
/// ```
class AuthChange extends StatelessWidget {
  const AuthChange({super.key, required this.builder});

  final Widget Function(User?) builder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        return builder(snapshot.data);
      },
    );
  }
}
