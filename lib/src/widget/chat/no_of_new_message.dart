import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

///
class NoOfNewMessageBadge extends StatelessWidget with FirebaseHelper {
  const NoOfNewMessageBadge({
    super.key,
    required this.room,
    this.builder,
  });

  final Room room;
  final Widget Function(int)? builder;

  @override
  String get uid => UserService.instance.uid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: noOfNewMessageUserRef(room.id, uid).onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        if (snapshot.hasData == false) const SizedBox.shrink();
        final data = snapshot.data;

        //
        final int no = (data?.snapshot.value ?? 0) as int;

        return builder?.call(no) ??
            (no == 0
                ? const SizedBox.shrink()
                : Badge(
                    backgroundColor: Colors.orange.shade900,
                    label: Text('$no'),
                  ));
      },
    );
  }
}
