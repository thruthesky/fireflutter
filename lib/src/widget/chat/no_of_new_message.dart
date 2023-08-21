import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class NoOfNewMessage extends StatelessWidget with FireFlutter {
  const NoOfNewMessage({
    super.key,
    required this.room,
  });

  final Room room;
  @override
  String get uid => UserService.instance.uid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: noOfNewMessageRef(room.id, uid).onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        if (snapshot.hasData == false) const SizedBox.shrink();
        final data = snapshot.data;

        final no = data?.snapshot.value ?? 0;
        if (no == 0) return const SizedBox.shrink();

        return Badge(
          backgroundColor: Theme.of(context).colorScheme.error,
          label: Text('$no'),
        );
      },
    );
  }
}
