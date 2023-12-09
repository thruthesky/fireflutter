import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// Display an alert box.
///
/// It requires build context where [toast] does not.
Future alert({
  required BuildContext context,
  String? title,
  required String message,
}) {
  if (FireFlutterService.instance.custom.alert != null) {
    return FireFlutterService.instance.custom.alert!(
      context: context,
      title: title ?? '',
      message: message,
    );
  }
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: title == null ? null : Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr.ok),
          ),
        ],
      );
    },
  );
}
