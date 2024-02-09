import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

/// User Tile
///
/// Use this widget to display a user's information in a list.
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
  final UserModel user;
  final EdgeInsetsGeometry? padding;
  final Function(UserModel)? onTap;
  final Widget? trailing;
  final bool? displayUid;
  final bool displayStateMessage;
  final bool displayBirth;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final child = Padding(
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
    );
    if (onTap != null) {
      return InkWell(
        onTap: () => onTap!(user),
        child: child,
      );
    } else {
      return child;
    }
  }
}
