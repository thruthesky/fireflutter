import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class UserName extends StatelessWidget {
  const UserName({
    required this.uid,
    this.style,
    this.maxLines,
    this.overflow,
    this.padding = const EdgeInsets.all(0.0),
    Key? key,
  }) : super(key: key);
  final String uid;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) {
    return UserDoc(
      uid: uid,
      // loader: SizedBox.shrink(),
      builder: (u) => u.hasDisplayName
          ? Padding(
              padding: padding,
              child: Text(
                u.displayName,
                style: style,
                maxLines: maxLines,
                overflow: overflow,
              ),
            )
          : SizedBox.shrink(),
    );
  }
}
