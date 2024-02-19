import 'package:flutter/material.dart';

class LabelField extends StatelessWidget {
  const LabelField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType,
    this.obscureText = false,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;

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
          child: Text(label),
        ),
        TextField(
          keyboardType: keyboardType,
          controller: controller,
          obscureText: obscureText,
        ),
      ],
    );
  }
}
