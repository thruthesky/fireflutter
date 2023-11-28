import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// UserDocReady
///
/// Builder widget that returns a FireFlutter [User] object when the user
/// document is available.
///
/// Note that this widget is different from [UserDoc] widget and [AuthChange]
/// widget.
///
/// [AuthChange] rebuilds the widget whenever the user authentication state
/// changes from/to the firebase authentication while [UserDoc] rebuilds the
/// widget whenever the user document is updated.
///
/// [UserDocReady] does NOT rebuild the widget on the user's document updates.
/// It listens [UserService.documentChanges] behavior subject event and
/// rebuilds the widget when the user document is loaded, or if it is already
/// loaded, or uid of the document changes. If the docuemnt is not available,
/// it will not display anything.
///
///
class UserDocReady extends StatelessWidget {
  const UserDocReady({super.key, required this.builder});

  final Widget Function(User) builder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: UserService.instance.documentChanges.distinct(
        // when the user logs out, the user document is null. So, the next is null.
        (prev, next) => next == null || prev?.uid == next.uid,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || snapshot.data == null) {
          return const SizedBox.shrink();
        }

        return builder(snapshot.data!);
      },
    );
  }
}
