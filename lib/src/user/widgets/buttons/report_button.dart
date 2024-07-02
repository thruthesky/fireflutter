import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ReportButton extends StatelessWidget {
  const ReportButton({
    super.key,
    this.uid,
    this.chatRoomId,
    this.category,
    this.postId,
    this.commentId,
    this.notify = true,
  });

  final String? uid;
  final String? chatRoomId;
  final String? category;
  final String? postId;
  final String? commentId;
  final bool notify;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final re = await input(
          context: context,
          title: T.reportInputTitle.tr,
          subtitle: T.reportInputMessage.tr,
          hintText: T.reportInputHint.tr,
        );
        if (re == null || re == '') return;
        await Report.create(
          context: context,
          otherUserUid: uid,
          chatRoomId: chatRoomId,
          category: category,
          postId: postId,
          commentId: commentId,
          reason: re,
          notify: notify,
        );
      },
      child: Text(T.report.tr),
    );
  }
}
