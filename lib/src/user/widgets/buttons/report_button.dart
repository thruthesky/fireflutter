import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class ReportButton extends StatelessWidget {
  const ReportButton({
    super.key,
    this.uid,
    this.chatRoomId,
    this.category,
    this.postId,
    this.commentId,
  });

  final String? uid;
  final String? chatRoomId;
  final String? category;
  final String? postId;
  final String? commentId;

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
        await ReportModel.create(
          otherUserUid: uid,
          chatRoomId: chatRoomId,
          category: category,
          postId: postId,
          commentId: commentId,
          reason: re,
        );
      },
      child: Text(T.report.tr),
    );
  }
}
