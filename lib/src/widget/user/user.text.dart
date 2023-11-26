import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// UserText
///
/// This widget displays the value of the user's field.
///
///
/// [user] is the user model. You may use this if you already have the user model
/// and you want to display the value of the user's field fast (without loader & blinking).
///
/// [uid] is the user's uid. You may use this if you don't have the user model
///
/// Example
/// ```dart
/// UserText(
///   user: message.mine ? my : null,
///   uid: message.mine ? null : message.uid,
///   field: 'name',
///   style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
/// )
/// ```
class UserText extends StatefulWidget {
  const UserText({
    super.key,
    this.uid,
    this.user,
    this.field = '',
    this.overflow,
    this.maxLines,
    this.style,
    this.showBlocked = false,
  }) : assert(user != null || uid != null);

  final String? uid;
  final User? user;
  final String field;
  final TextOverflow? overflow;
  final int? maxLines;
  final TextStyle? style;
  final bool showBlocked;

  @override
  State<UserText> createState() => _UserTextState();
}

class _UserTextState extends State<UserText> {
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

    String val = user!.data[widget.field] ?? '';
    if ((my?.hasBlocked(user!.uid) ?? false) && !widget.showBlocked) {
      val = tr.blocked;
    }
    return Text(
      val,
      style: widget.style ?? const TextStyle(fontWeight: FontWeight.bold),
      maxLines: widget.maxLines ?? 1,
      overflow: widget.overflow ?? TextOverflow.ellipsis,
    );
  }
}
