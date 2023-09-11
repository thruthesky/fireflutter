import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

///
class NoOfNewMessageBadge extends StatelessWidget with FirebaseHelper {
  const NoOfNewMessageBadge({
    super.key,
    required this.room,
  });

  final Room room;
  @override
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: noOfNewMessageRef(uid: myUid!).child(room.roomId).onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        if (snapshot.hasData == false) const SizedBox.shrink();
        final data = snapshot.data;

        //
        final no = data?.snapshot.value ?? 0;
        if (no == 0) return const SizedBox.shrink();

        return Badge(
          backgroundColor: Colors.orange.shade900,
          label: Text('$no'),
        );
      },
    );
  }
}
