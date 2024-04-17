import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShareButton extends StatelessWidget {
  const ShareButton({
    super.key,
    this.user,
    this.post,
  }) : assert(user != null || post != null);

  final User? user;
  final Post? post;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        String link = "";
        if (user != null) {
          link = DynamicLinkService.instance.createUserLink(user!);
        }
        if (post != null) {
          link = DynamicLinkService.instance.createPostLink(post!);
        }
        Clipboard.setData(ClipboardData(text: link));
        alert(
          context: context,
          title: "Share",
          message: link,
        );
      },
      // TODO tr
      child: const Text("Share"),
    );
  }
}
