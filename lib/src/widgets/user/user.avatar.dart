import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// UserAvatar
///
///
/// [user] is the user model.
///
/// [uid] is the user uid.
/// If [user] is null, [uid] is required.
///
/// [size] is the avatar size.
///
/// [defaultIcon] is the default icon when user photoUrl is null.
///
class UserAvatar extends StatefulWidget {
  const UserAvatar({super.key, this.user, this.uid, this.size = 32, this.defaultIcon})
      : assert(user != null || uid != null);

  final User? user;
  final String? uid;
  final double size;
  final Widget? defaultIcon;

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
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
    if (user == null) return defaultIcon();
    if (user?.photoUrl == null || user?.photoUrl == '') return defaultIcon();

    return Avatar(url: user!.photoUrl, size: widget.size);
  }

  Widget defaultIcon() {
    return widget.defaultIcon ??
        Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person,
            size: widget.size / 2,
          ),
        );
  }
}
