import 'package:flutter/material.dart';
import 'package:fireflutter/fireflutter.dart';

class ForumPoint extends StatelessWidget with ForumMixin {
  const ForumPoint({
    Key? key,
    required this.uid,
    required this.point,
    this.padding = const EdgeInsets.only(
      left: 16,
      bottom: 8,
    ),
  }) : super(key: key);

  final String uid;
  final int point;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: UserService.instance.get(uid),
      builder: ((cc, snapshotUserData) {
        if (snapshotUserData.hasData) {
          final UserModel user = snapshotUserData.data as UserModel;
          return point == 0
              ? SizedBox.shrink()
              : Padding(
                  padding: padding,
                  child: Text(
                    '* ${user.displayName} earned $point points.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                );
        } else {
          return SizedBox.shrink();
        }
      }),
    );
  }
}
