import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// UserReady
///
/// Builder widget that returns a [User] object when the "authStateChanges"
/// event fires.
///
/// This widget is useful for determining if the user is logged in or not.
/// If the user is logged in, the [User] object will be returned. Or else,
/// the [User] object will be null.
///
/// Example:
/// ```dart
/// UserReady(builder: (user) {
///   if (user == null) {
///     return const Text('User is not logged in.');
///   }
///   return const Text('User is logged in.');
/// }
/// ```
class UserReady extends StatelessWidget {
  const UserReady({super.key, required this.builder});

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
