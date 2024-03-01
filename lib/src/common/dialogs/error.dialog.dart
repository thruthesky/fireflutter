import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  const ErrorDialog({super.key, this.title, required this.message});

  final String? title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text(
          title ?? T.error.tr,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          message,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(T.ok.tr),
          ),
        ]);
  }
}
