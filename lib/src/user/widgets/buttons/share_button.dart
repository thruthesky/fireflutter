import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

/// Share Button Widget that shares a link to the user or post.
class ShareButton extends StatelessWidget {
  const ShareButton({
    super.key,
    required this.link,
    this.textButton = false,
  });
  final Uri link;
  final bool textButton;

  const ShareButton.textButton({
    required this.link,
  }) : textButton = true;

  @override
  Widget build(BuildContext context) {
    if (textButton) {
      return TextButton(
        onPressed: () => Share.shareUri(link),
        child: Text(T.share.tr),
      );
    }
    return ElevatedButton(
      onPressed: () => Share.shareUri(link),
      child: Text(T.share.tr),
    );
  }
}
