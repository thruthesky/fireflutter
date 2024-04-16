import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class BlockButton extends StatelessWidget {
  const BlockButton({
    super.key,
    required this.uid,
    this.filledIcon = false,
    this.blockIcon,
    this.unblockIcon,
    this.padding,
    this.ask = true,
    this.inform = true,
  });

  final String uid;
  final bool filledIcon;
  final Widget? blockIcon;
  final Widget? unblockIcon;
  final EdgeInsetsGeometry? padding;
  final bool ask;
  final bool inform;

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

  onPressed(BuildContext context) async {
    final re = await confirm(
      context: context,
      title: iHave.blocked(uid)
          ? T.unblockConfirmTitle.tr
          : T.blockConfirmTitle.tr,
      message: iHave.blocked(uid)
          ? T.unblockConfirmMessage.tr
          : T.blockConfirmMessage.tr,
    );
    if (re != true) return;
    await UserService.instance.block(context: context, otherUserUid: uid);
  }
}
