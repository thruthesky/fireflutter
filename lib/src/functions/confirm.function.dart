import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// Confirm dialgo
///
/// It requires build context where [toast] does not.
Future<bool?> confirm({required BuildContext context, required String title, required String message}) {
  if (FireFlutterService.instance.custom.confirm != null) {
    return FireFlutterService.instance.custom.confirm!(
      context: context,
      title: title,
      message: message,
      actions: <Widget>[
        TextButton(
          key: const Key('ConfirmNoButton'),
          onPressed: () => Navigator.pop(context, false),
          child: Text(tr.no),
        ),
        TextButton(
          key: const Key('ConfirmYesButton'),
          onPressed: () => Navigator.pop(context, true),
          child: Text(tr.yes),
        ),
      ],
    );
  }

  return showDialog<bool?>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            key: const Key('ConfirmNoButton'),
            onPressed: () => Navigator.pop(context, false),
            child: Text(tr.no),
          ),
          TextButton(
            key: const Key('ConfirmYesButton'),
            onPressed: () => Navigator.pop(context, true),
            child: Text(tr.yes),
          ),
        ],
      );
    },
  );
}
