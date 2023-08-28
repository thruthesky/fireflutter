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
/// [padding] is the padding of the avatar. Default is EdgeInsets.all(0). See
/// the details on [Avatar]
///
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.user,
    this.uid,
    this.size = 32,
    this.defaultIcon,
    this.borderWidth = 0,
    this.borderColor = Colors.transparent,
    this.radius = 10,
    this.padding = const EdgeInsets.all(0),
    this.onTap,
  }) : assert(user == null || uid == null);

  final User? user;
  final String? uid;
  final double size;
  final Widget? defaultIcon;
  final double borderWidth;
  final Color borderColor;
  final double radius;
  final EdgeInsets padding;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    // if onTap is null, then, don't capture the gesture event. Just return avatar.
    if (user != null) {
      return _buildAvatar(user!);
    } else {
      return FutureBuilder<User?>(
        future: UserService.instance.get(uid!),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _buildAvatar(snapshot.data!);
          } else {
            return buildDefaultIcon();
          }
        },
      );
    }
  }

  _buildAvatar(User user) {
    Widget child;
    if (user.photoUrl == '') {
      child = buildDefaultIcon();
    } else {
      child = Avatar(
        url: user.photoUrl,
        size: size,
        borderWidth: borderWidth,
        borderColor: borderColor,
        radius: radius,
        padding: padding,
      );
    }

    if (onTap == null) {
      return child;
    } else {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: child,
      );
    }
  }

  Widget buildDefaultIcon() {
    return defaultIcon ??
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: borderColor,
              width: borderWidth,
            ),
          ),
          child: Icon(
            Icons.person,
            size: size / 2,
          ),
        );
  }
}
