import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// UserBlocked
///
/// [UserBlocked] is a helper widget that simplifies the use of [UserDoc] widget.
///
/// [blockedBuilder] is called when the user is blocked.
///
/// [notBlockedBuilder] is called when the user is not blocked.
class UserBlocked extends StatelessWidget {
  const UserBlocked({
    super.key,
    required this.blockedBuilder,
    required this.notBlockedBuilder,
    this.otherUid,
    this.otherUser,

    /// NOTE: make sure that user by is updated user because the User data
    /// might be cached with old data.
  }) : assert(otherUid != null || otherUser != null);

  final Widget Function(BuildContext context) blockedBuilder;
  final Widget Function(BuildContext context) notBlockedBuilder;
  final String? otherUid;
  final User? otherUser;

  @override
  Widget build(BuildContext context) {
    return MyDoc(
      builder: (i) {
        if (i.haveBlocked(otherUid ?? otherUser!.uid)) {
          return blockedBuilder(context);
        } else {
          return notBlockedBuilder(context);
        }
      },
    );
  }
}
