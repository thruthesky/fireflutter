import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Setting extends StatelessWidget {
  const Setting({
    super.key,
    required this.path,
    this.uid,
    required this.builder,
    this.loading,
  });

  final String path;
  final String? uid;
  final Widget Function(dynamic value) builder;
  final Widget? loading;

  DatabaseReference get nodePath {
    final p =
        FirebaseDatabase.instance.ref('settings').child(uid ?? FirebaseAuth.instance.currentUser!.uid).child(path);

    return p;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: nodePath.onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> event) {
        if (event.connectionState == ConnectionState.waiting) {
          return loading ?? const CircularProgressIndicator.adaptive();
        }
        if (event.hasError) {
          return Text('Error; ${event.error}');
        }
        if (event.hasData && event.data!.snapshot.exists) {
          return builder(event.data!.snapshot.value);
        } else {
          return builder(null);
        }
      },
    );
  }
}
