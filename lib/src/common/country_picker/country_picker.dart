import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class CountryPicker extends StatefulWidget {
  const CountryPicker({
    super.key,
    this.filters,
    this.search = true,
    this.headerBuilder,
    this.labelBuilder,
    required this.onChanged,
  });

  /// List of country codes to show in the list.
  final List<String>? filters;
  final bool search;
  final Widget Function()? headerBuilder;
  final Widget Function(Map<String, String>)? labelBuilder;
  final void Function(Map<String, String>) onChanged;

  @override
  State<CountryPicker> createState() => _CountryPickerState();
}

class _CountryPickerState extends State<CountryPicker> {
  Map<String, String> selectedCountry = {};
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return CountryPickerListView(
              search: widget.search,
              onChanged: (v) {
                setState(() {
                  selectedCountry = v;
                });
                widget.onChanged(v);
              },
              headerBuilder: widget.headerBuilder,
              filters: widget.filters,
            );
          },
        );
      },
      child: widget.labelBuilder?.call(selectedCountry) ??
          const Text('CountryPicker'),
    );
  }
}
