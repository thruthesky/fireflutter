import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class UserBlocked extends StatefulWidget {
  const UserBlocked({
    super.key,
    required this.blockedBuilder,
    required this.notBlockedBuilder,
    this.uid,
    this.user,
    this.uidBy,

    /// NOTE: make sure that user by is updated user because the User data
    /// might be cached with old data.
    this.userBy,
  }) : assert(uid != null || user != null);

  final Widget Function(BuildContext context) blockedBuilder;
  final Widget Function(BuildContext context) notBlockedBuilder;
  final String? uid;
  final User? user;

  final String? uidBy;
  final User? userBy;

  @override
  State<UserBlocked> createState() => _UserBlockState();
}

class _UserBlockState extends State<UserBlocked> {
  String? uid;
  User? userBy;

  @override
  void initState() {
    super.initState();
    initUser();
  }

  initUser() async {
    // We only need the uid, no need to get user (so that it'll be faster)
    uid = widget.user?.uid ?? widget.uid!;
    userBy = await getUserBy();
    setState(() {});
  }

  getUserBy() async {
    if (widget.userBy != null) return widget.userBy;
    if (widget.uidBy != null) return await User.get(widget.uidBy!);
    return my ?? await User.get(myUid!);
  }

  @override
  Widget build(BuildContext context) {
    if (uid == null) return const SizedBox.shrink();
    if (userBy == null) return const CircularProgressIndicator.adaptive();
    return userBy!.hasBlocked(uid!) ? widget.blockedBuilder(context) : widget.notBlockedBuilder(context);
  }
}
