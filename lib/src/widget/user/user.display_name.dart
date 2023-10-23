import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// UserDisplayName
///
/// This widget displays the user's display name. If the user's display name is empty
/// then, it will display the name of the user.
///
/// [user] is the user model. You may use this if you already have the user model
/// and you want to display the user's display name more fast (without loader & blinking).
class UserDisplayName extends StatefulWidget {
  const UserDisplayName({
    super.key,
    this.uid,
    this.user,
    this.overflow,
    this.maxLines,
    this.style,
  }) : assert(user != null || uid != null);

  final String? uid;
  final User? user;
  final TextOverflow? overflow;
  final int? maxLines;
  final TextStyle? style;

  @override
  State<UserDisplayName> createState() => _UserDisplayNameState();
}

class _UserDisplayNameState extends State<UserDisplayName> {
  User? user;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      user = widget.user;
    } else {
      UserService.instance.get(widget.uid!).then((value) {
        if (mounted) {
          setState(() {
            user = value;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const SizedBox.shrink();
    }

    String displayName = user!.getDisplayName;
    if (my?.hasBlocked(user!.uid) ?? false) {
      displayName = tr.blocked;
    }
    return Text(
      displayName,
      style: widget.style ?? const TextStyle(fontWeight: FontWeight.bold),
      maxLines: widget.maxLines ?? 1,
      overflow: widget.overflow ?? TextOverflow.ellipsis,
    );
  }
}
