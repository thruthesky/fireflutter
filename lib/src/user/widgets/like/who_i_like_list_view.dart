import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/widgets.dart';

class WhoILikeListView extends StatelessWidget {
  const WhoILikeListView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FirebaseDatabaseListView(
      query: Ref.userWhoILike.child(myUid!),
      itemBuilder: (context, snapshot) {
        return UserTile.fromUid(uid: snapshot.key!);
      },
    );
  }
}
