import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class CountryPicker extends StatelessWidget {
  const CountryPicker({
    super.key,
    this.filters,
    required this.onChanged,
  });

  /// List of country codes to show in the list.
  final List<String>? filters;
  final void Function(Map<String, String>) onChanged;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return CountryPickerListView(
                onChanged: onChanged, filters: filters);
          },
        );
      },
      child: const Text('CountryPicker'),
    );
  }
}
