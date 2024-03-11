import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// User Tile
///
/// Use this widget to display a user's information in a list.
///
/// [onTap] is optional. If not provided, the fireship will open the user's
/// public profile screen. If provided, the function will be called when the
/// user's tile is tapped.
class UserTile extends StatelessWidget {
  const UserTile({
    Key? key,
    required this.user,
    this.padding,
    this.onTap,
    this.trailing,
    this.displayUid,
    this.displayStateMessage = false,
    this.displayBirth = false,
    this.bottom,
  }) : super(key: key);
  final User user;
  final EdgeInsetsGeometry? padding;
  final Function(User)? onTap;
  final Widget? trailing;
  final bool? displayUid;
  final bool displayStateMessage;
  final bool displayBirth;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap != null
          ? onTap!.call(user)
          : UserService.instance.showPublicProfileScreen(
              context: context,
              uid: user.uid,
            ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                UserAvatar(uid: user.uid),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (displayUid ?? false) Text(user.uid),
                      if (displayStateMessage) Text(user.stateMessage),
                      if (displayBirth) Text(user.age),
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 16),
                  trailing!,
                ],
              ],
            ),
            if (bottom != null) ...[
              const SizedBox(height: 16),
              bottom!,
            ],
          ],
        ),
      ),
    );
  }

  static fromUid({
    required String uid,
    EdgeInsetsGeometry? padding,
    Function(User)? onTap,
    Widget? trailing,
    bool? displayUid,
    bool displayStateMessage = false,
    bool displayBirth = false,
    Widget? bottom,
  }) {
    return FutureBuilder<User?>(
        future: User.get(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return UserTile(
              user: User.fromUid(uid),
              padding: padding,
              onTap: onTap,
              trailing: trailing,
              displayUid: displayUid,
              displayStateMessage: displayStateMessage,
              displayBirth: displayBirth,
              bottom: bottom,
            );
          }

          return UserTile(
            user: snapshot.data ?? User.fromUid(uid),
            padding: padding,
            onTap: onTap,
            trailing: trailing,
            displayUid: displayUid,
            displayStateMessage: displayStateMessage,
            displayBirth: displayBirth,
            bottom: bottom,
          );
        });
  }
}
