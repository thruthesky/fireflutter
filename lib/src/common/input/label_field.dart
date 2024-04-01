import 'package:flutter/material.dart';

class LabelField extends StatelessWidget {
  const LabelField({
    super.key,
    required this.label,
    required this.controller,
    this.description,
    this.keyboardType,
    this.obscureText = false,
    this.decoration,
    this.minLines,
    this.maxLines,
  });

  final String label;
  final TextEditingController controller;
  final String? description;
  final TextInputType? keyboardType;
  final bool obscureText;
  final InputDecoration? decoration;

  final int? minLines;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(
            left: 10,
            bottom: 2,
          ),
          child: Text(label, style: Theme.of(context).textTheme.labelMedium),
        ),
        TextField(
          keyboardType: keyboardType,
          controller: controller,
          obscureText: obscureText,
          decoration: decoration ?? const InputDecoration(),
          minLines: minLines,
          maxLines: maxLines,
        ),
        if (description != null)
          Padding(
            padding: const EdgeInsets.only(
              left: 10,
              top: 4,
            ),
            child: Text(
              description!,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
      ],
    );
  }
}
