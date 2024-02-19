import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class CountryPicker extends StatefulWidget {
  const CountryPicker({
    super.key,
    this.initialValue,
    this.filters,
    this.search = true,
    this.headerBuilder,
    this.itemBuilder,
    this.labelBuilder,
    required this.onChanged,
  });

  /// The initial value of the country picker.
  /// If this value is provided, then the [onChagned] will be called immediately
  /// with this value.
  final String? initialValue;

  /// List of country codes to show in the list. The country codes should be in
  /// ISO 3166-1 alpha-2 format.
  final List<String>? filters;

  final bool search;
  final Widget Function()? headerBuilder;
  final Widget Function(CountryCode)? itemBuilder;
  final Widget Function(CountryCode?)? labelBuilder;
  final void Function(CountryCode) onChanged;

  @override
  State<CountryPicker> createState() => _CountryPickerState();
}

class _CountryPickerState extends State<CountryPicker> {
  CountryCode? selectedCountry;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      final CountryCode country = countryList().firstWhere(
        (e) => e.alpha2 == widget.initialValue,
      );
      selectedCountry = country;
      widget.onChanged(country);
    }
  }

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
              itemBuilder: widget.itemBuilder,
              filters: widget.filters,
            );
          },
        );
      },
      child: lableBuilder(),
    );
  }

  Widget lableBuilder() {
    if (widget.labelBuilder != null) {
      return widget.labelBuilder!(selectedCountry);
    }

    if (selectedCountry == null) {
      return const Text('Choose your country');
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(selectedCountry!.flag,
              style: Theme.of(context).textTheme.titleLarge!),
          const SizedBox(width: 8),
          Text(selectedCountry!.officialName),
        ],
      );
    }
  }
}
