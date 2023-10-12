import 'package:firebase_core/firebase_core.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/model/report/report.dart';
import 'package:flutter/material.dart';

class ReportService {
  static ReportService? _instance;
  static ReportService get instance => _instance ?? ReportService._();

  ReportService._();

  /// Shows the Edit Post as a dialog
  ///
  /// [type] in onExists call back is one of 'user', 'comment', 'post'.
  Future<bool?> showReportDialog({
    required BuildContext context,
    String? otherUid,
    String? postId,
    String? commentId,
    Function(String id, String type)? onExists,
  }) async {
    assert(otherUid != null || postId != null || commentId != null);
    if (notLoggedIn) {
      toast(title: tr.loginFirstTitle, message: tr.loginFirstMessage);
      return null;
    }

    final info = Report.info(
      commentId: commentId,
      otherUid: otherUid,
      postId: postId,
    );

    final re = await Report.get(info.id);

    // If the user has already reported?
    if (re?.reporters.contains(myUid) == true) {
      onExists?.call(info.id, info.type) ??
          toast(
            title: tr.alreadyReportedTitle,
            message: tr.alreadyReportedMessage.replaceAll("#type", info.type),
          );
      return null;
    }

    if (context.mounted) {
      return await showDialog<bool?>(
        context: context,
        builder: (context) {
          final reason = TextEditingController();

          return AlertDialog(
            title: const Text('Report'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Why do you want to report this ${info.type}? (optional)',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                TextField(
                  controller: reason,
                  decoration: const InputDecoration(
                    label: Text('Reason'),
                  ),
                  minLines: 2,
                  maxLines: 5,
                )
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  await Report.create(reason: reason.text, otherUid: otherUid, postId: postId, commentId: commentId);
                  if (context.mounted) {
                    return Navigator.of(context).pop(true);
                  }
                },
                child: const Text('Report'),
              ),
            ],
          );
        },
      );
    }
    return null;
  }
}
