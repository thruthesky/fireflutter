import 'package:flutter/material.dart';

class ReportCustomize {
  Future<bool?> Function({
    required BuildContext context,
    String? otherUid,
    String? postId,
    String? commentId,
    Function(String id, String type)? onExists,
  })? showReportDialog;
  ReportCustomize({
    this.showReportDialog,
  });
}
