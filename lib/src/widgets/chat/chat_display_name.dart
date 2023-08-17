import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ChatDisplayName extends StatefulWidget {
  const ChatDisplayName({
    super.key,
    required this.uid,
    this.textStyle = const TextStyle(fontWeight: FontWeight.bold),
  });

  final String uid;
  final TextStyle textStyle;

  @override
  State<ChatDisplayName> createState() => _ChatDisplayNameState();
}

class _ChatDisplayNameState extends State<ChatDisplayName> {
  User? user;

  @override
  void initState() {
    super.initState();
    UserService.instance.get(widget.uid).then((value) {
      if (mounted) {
        setState(() {
          user = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const SizedBox.shrink();
    }
    return user!.displayName.isEmpty == true
        ? const SizedBox.shrink()
        : Text(
            user!.displayName,
            style: widget.textStyle,
          );
  }
}