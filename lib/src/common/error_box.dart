import 'package:flutter/material.dart';

class ErrorBox extends StatelessWidget {
  const ErrorBox({
    super.key,
    this.title,
    required this.message,
  });

  final String? title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null)
          Text(
            title!,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        const SizedBox(height: 8),
        Text(message),
      ],
    );
  }
}
