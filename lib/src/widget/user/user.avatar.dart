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
/// * If [uid] and [user] is null, then it will return [defaultIcon].
///
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.user,
    this.uid,
    this.size = 32,
    this.defaultIcon,
    this.showBlocked = false,
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
  final bool showBlocked;
  final double borderWidth;
  final Color borderColor;
  final double radius;
  final EdgeInsets padding;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    Widget child;
    // if onTap is null, then, don't capture the gesture event. Just return avatar.
    if (user != null) {
      child = _buildAvatar(user!);
    } else if (uid != null) {
      child = FutureBuilder<User?>(
        future: UserService.instance.get(uid!),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _buildAvatar(snapshot.data!);
          } else {
            return buildDefaultIcon();
          }
        },
      );
    } else {
      child = buildDefaultIcon();
    }
    return onTap == null
        ? child
        : GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: child,
          );
  }

  // Build avatar for the user.
  _buildAvatar(User user) {
    // For the blocked users,
    if (my != null && my!.blockedUsers.contains(user.uid) && showBlocked == false) {
      return buildDefaultIcon();
    }

    if (user.photoUrl == '') {
      return buildDefaultIcon();
    } else {
      return Avatar(
        url: user.photoUrl,
        size: size,
        borderWidth: borderWidth,
        borderColor: borderColor,
        radius: radius,
        padding: padding,
      );
    }
  }

  Widget buildDefaultIcon() {
    return defaultIcon ??
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: borderColor,
              width: borderWidth,
            ),
          ),
          child: Icon(
            Icons.person,
            size: size / 1.2,
          ),
        );
  }
}
