import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// Prompt a dialog to get user input.
///
/// [context] is the build context.
/// [title] is the title of the dialog.
/// [subtitle] is the subtitle of the dialog.
/// [hintText] is the hintText of the input.
/// [initialValue] is the initial value of the input field.
///
/// Returns the user input.
///
/// Used in:
/// - admin.messaging.screen.dart
Future<String?> prompt({
  required BuildContext context,
  required String title,
  String? subtitle,
  required String hintText,
  String? initialValue,
}) {
  if (FireFlutterService.instance.custom.prompt != null) {
    return FireFlutterService.instance.custom.prompt!(
      context: context,
      title: title,
      subtitle: subtitle,
      hintText: hintText,
      initialValue: initialValue,
    );
  }
  return showDialog<String?>(
    context: context,
    builder: (BuildContext context) {
      final controller = TextEditingController(text: initialValue);
      return AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (subtitle != null) ...[
              Text(subtitle),
              const SizedBox(height: sizeMd),
            ],
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(tr.ok),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr.cancel),
          ),
        ],
      );
    },
  );
}
