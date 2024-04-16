import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class BlockButton extends StatelessWidget {
  const BlockButton({
    super.key,
    required this.uid,
    this.filledIcon = false,
    this.textButton = false,
    this.blockIcon,
    this.unblockIcon,
    this.padding,
    this.ask = true,
    this.notify = true,
  });

  final String uid;
  final bool filledIcon;
  final bool textButton;
  final Widget? blockIcon;
  final Widget? unblockIcon;
  final EdgeInsetsGeometry? padding;
  final bool ask;
  final bool notify;

  @override
  Widget build(BuildContext context) {
    return MyDoc(
      builder: (iHave) {
        if (iHave == null || iHave.uid == uid) return const SizedBox();

        if (filledIcon) {
          return IconButton.filled(
            padding: padding,
            onPressed: () => onPressed(context),
            icon: iHave.blocked(uid) ? blockIcon! : unblockIcon!,
          );
        } else if (textButton) {
          return TextButton(
            onPressed: () => onPressed(context),
            child: Text(iHave.blocked(uid) ? T.unblock.tr : T.block.tr),
          );
        } else {
          return ElevatedButton(
            onPressed: () => onPressed(context),
            child: Text(iHave.blocked(uid) ? T.unblock.tr : T.block.tr),
          );
        }
      },
    );
  }

  /// variant of widget Block button this widget is a icon filled button
  ///
  const BlockButton.filledIcon({
    Key? key,
    required String uid,
    required Widget blockIcon,
    required Widget unblockIcon,
    EdgeInsetsGeometry? padding,
  }) : this(
          key: key,
          uid: uid,
          filledIcon: true,
          blockIcon: blockIcon,
          unblockIcon: unblockIcon,
          padding: padding,
        );
  const BlockButton.textButton({
    Key? key,
    required String uid,
    EdgeInsetsGeometry? padding,
  }) : this(
          key: key,
          uid: uid,
          textButton: true,
          padding: padding,
        );

  onPressed(BuildContext context) async {
    await UserService.instance.block(
      context: context,
      otherUserUid: uid,
      ask: ask,
      notify: notify,
    );
  }
}
