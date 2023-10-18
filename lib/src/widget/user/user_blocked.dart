import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class UserBlocked extends StatefulWidget {
  const UserBlocked({
    super.key,
    required this.blockedBuilder,
    required this.notBlockedBuilder,
    this.uid,
    this.user,
  }) : assert(uid != null || user != null);

  final Widget Function(BuildContext) blockedBuilder;
  final Widget Function(BuildContext) notBlockedBuilder;
  final String? uid;
  final User? user;

  @override
  State<UserBlocked> createState() => _UserBlockState();
}

class _UserBlockState extends State<UserBlocked> {
  User? user;

  @override
  void initState() {
    super.initState();
    initUser();
  }

  initUser() async {
    user = widget.user ?? await User.get(widget.uid!);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) return const SizedBox.shrink();
    return user!.hasBlocked(myUid ?? '') ? widget.blockedBuilder(context) : widget.notBlockedBuilder(context);
  }
}
