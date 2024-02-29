import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class BlockButton extends StatelessWidget {
  const BlockButton({super.key, required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context) {
    return MyDoc(
      builder: (iHave) {
        if (iHave == null) return const SizedBox();
        return ElevatedButton(
          onPressed: () async {
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
            await my?.block(uid);
          },
          child: Text(iHave.blocked(uid) ? T.unblock.tr : T.block.tr),
        );
      },
    );
  }

  // variant of widget Block button this widget is a icon filled button
  //
  static Widget filledIcon(
      {Key? key,
      required BuildContext context,
      required String uid,
      required Widget blockIcon,
      required Widget unblockIcon,
      EdgeInsetsGeometry? padding}) {
    return MyDoc(
      builder: (iHave) {
        if (iHave == null) return const SizedBox();
        return IconButton.filled(
          padding: padding,
          onPressed: () async {
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
            await my?.block(uid);
          },
          icon: iHave.blocked(uid) ? blockIcon : unblockIcon,
        );
      },
    );
  }
}
