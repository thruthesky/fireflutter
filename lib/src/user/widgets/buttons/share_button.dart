import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

/// Share Button Widget that shares a link to the user or post.
class ShareButton extends StatelessWidget {
  const ShareButton({
    super.key,
    this.user,
    this.post,
    this.onTap,
  })  : assert(user != null || post != null || onTap != null),
        _textButton = false;

  final User? user;
  final Post? post;
  final Uri Function()? onTap;

  final bool _textButton;

  const ShareButton.textButton({
    this.user,
    this.post,
    this.onTap,
  })  : assert(user != null || post != null || onTap != null),
        _textButton = true;

  @override
  Widget build(BuildContext context) {
    if (_textButton) {
      return TextButton(
        onPressed: _onPressed,
        child: Text(T.share.tr),
      );
    }
    return ElevatedButton(
      onPressed: _onPressed,
      child: Text(T.share.tr),
    );
  }

  Future<void> _onPressed() async {
    late Uri link;
    if (user != null) {
      link = DynamicLinkService.instance.createUserLink(user!);
    } else if (post != null) {
      link = DynamicLinkService.instance.createPostLink(post!);
    } else if (onTap != null) {
      link = onTap!();
    } else {
      throw Exception("ShareButton: No user, post, or onTap provided.");
    }
    Share.shareUri(link);
  }
}
