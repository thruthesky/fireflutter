import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserBlock extends StatelessWidget {
  const UserBlock({
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
  Widget build(BuildContext context) {
    final user = user ?? User.get(uid!);
    return isBlocked ? blockedBuilder(context) : notBlockedBuilder(context);
  }
}
