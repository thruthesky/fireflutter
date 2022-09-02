// import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fireflutter/fireflutter.dart';

/// UserDoc
///
class UserDoc extends StatefulWidget {
  const UserDoc({
    required this.uid,
    required this.builder,
    this.loader = const Center(
      child: SizedBox(
        width: 10,
        height: 10,
        child: CircularProgressIndicator.adaptive(
          strokeWidth: 2,
        ),
      ),
    ),
    Key? key,
  }) : super(key: key);
  final String? uid;
  final Widget loader;
  final Widget Function(UserModel) builder;

  @override
  State<UserDoc> createState() => _UserDocState();
}

class _UserDocState extends State<UserDoc> {
  UserModel? user;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    if (widget.uid == null) {
      // debugPrint('---> _UserDocState() widget.uid == null');
    }
    try {
      user = await User.instance.get(widget.uid!);

      if (mounted) setState(() => null);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        debugPrint(
            '----> Error ${e.code} ${e.message} on "UserDoc::User.getOtherUserDoc()". This permission-denied error is silently ignore since it is not important.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) return widget.loader;
    return widget.builder(user!);
  }
}
