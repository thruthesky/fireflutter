import 'package:flutter/material.dart';

class JobFormDropdownField<T> extends StatelessWidget {
  const JobFormDropdownField({
    this.label,
    required this.value,
    required this.validator,
    required this.items,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  final String? label;
  final T value;
  final String? Function(T?) validator;
  final List<DropdownMenuItem<T>> items;
  final Function(T?) onChanged;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey),
    );
    final errorBorder = OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Text(
            label!,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
        SizedBox(height: 5),
        DropdownButtonFormField<T>(
          isExpanded: true,
          autovalidateMode: AutovalidateMode.always,
          validator: validator,
          value: value,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
            enabledBorder: border,
            focusedBorder: border,
            focusedErrorBorder: errorBorder,
            errorBorder: errorBorder,
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
