import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class WhoLikeMeListView extends StatelessWidget {
  const WhoLikeMeListView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FirebaseDatabaseListView(
      query: Ref.userWhoLikeMe.child(myUid!),
      itemBuilder: (context, snapshot) {
        return UserTile.fromUid(uid: snapshot.key!);
      },
    );
  }
}
