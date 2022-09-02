import 'package:flutter/material.dart';

class JobFormTextField extends StatelessWidget {
  JobFormTextField({
    required this.label,
    this.validator,
    this.initialValue,
    this.controller,
    required this.onChanged,
    this.keyboardType,
    this.maxLines,
    Key? key,
  }) : super(key: key);

  final String label;
  final String? Function(String?)? validator;
  final String? initialValue;
  final TextEditingController? controller;
  final Function(String) onChanged;
  final TextInputType? keyboardType;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey),
    );
    final errorBorder = OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red),
    );

    return TextFormField(
      key: UniqueKey(),
      initialValue: initialValue,
      controller: controller,
      autovalidateMode: AutovalidateMode.always,
      keyboardType: keyboardType,
      minLines: maxLines != null ? 2 : null,
      maxLines: maxLines,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        focusedBorder: border,
        enabledBorder: border,
        focusedErrorBorder: errorBorder,
        errorBorder: errorBorder,
      ),
    );
  }
}
