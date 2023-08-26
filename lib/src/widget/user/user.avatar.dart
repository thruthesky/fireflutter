import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// UserAvatar
///
///
/// [user] is the user model.
///
/// [uid] is the user uid.
///
/// If [user] and [uid] is null, then, it will show [defaultIcon].
///
/// [size] is the avatar size.
///
/// [defaultIcon] is the default icon when user photoUrl is null.
///
class UserAvatar extends StatefulWidget {
  const UserAvatar({
    super.key,
    this.user,
    this.uid,
    this.size = 32,
    this.defaultIcon,
    this.borderWidth = 0,
    this.borderColor = Colors.transparent,
    this.radius = 10,
    this.onTap,
  });

  final User? user;
  final String? uid;
  final double size;
  final Widget? defaultIcon;
  final double borderWidth;
  final Color borderColor;
  final double radius;
  final Function()? onTap;

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
    }
    if (widget.uid != null && widget.uid != '') {
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
    // if onTap is null, then, don't capture the gesture event. Just return avatar.
    if (widget.onTap == null) return _buildAvatar();
    return GestureDetector(
      onTap: widget.onTap,
      child: _buildAvatar(),
    );
  }

  _buildAvatar() {
    if (user == null) return defaultIcon();
    if (user?.photoUrl == null || user?.photoUrl == '') return defaultIcon();
    return Avatar(
      url: user!.photoUrl,
      size: widget.size,
      borderWidth: widget.borderWidth,
      borderColor: widget.borderColor,
      radius: widget.radius,
    );
  }

  Widget defaultIcon() {
    return widget.defaultIcon ??
        Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            border: Border.all(
              color: widget.borderColor,
              width: widget.borderWidth,
            ),
          ),
          child: Icon(
            Icons.person,
            size: widget.size / 2,
          ),
        );
  }
}
