import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class LanguagePicker extends StatefulWidget {
  const LanguagePicker({
    super.key,
    this.initialValue,
    this.filters,
    this.search = true,
    this.headerBuilder,
    this.itemBuilder,
    this.labelBuilder,
    this.isTile = false,
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
  final bool isTile;
  final Widget Function()? headerBuilder;
  final Widget Function(MapEntry)? itemBuilder;
  final Widget Function(String?)? labelBuilder;
  final void Function(String) onChanged;

  @override
  State<LanguagePicker> createState() => _LanguagePickerState();

  // variant of LanguagePicker if you want to use the language picker as a listTile
  // use LanguagePicker.tile()
  const LanguagePicker.tile({
    Key? key,
    String? initialValue,
    List<String>? filters,
    bool search = true,
    Widget Function()? headerBuilder,
    Widget Function(MapEntry)? itemBuilder,
    Widget Function(String?)? labelBuilder,
    required void Function(String) onChanged,
  }) : this(
            key: key,
            initialValue: initialValue,
            filters: filters,
            search: search,
            headerBuilder: headerBuilder,
            itemBuilder: itemBuilder,
            labelBuilder: labelBuilder,
            onChanged: onChanged,
            isTile: true);
}

class _LanguagePickerState extends State<LanguagePicker> {
  String? selectedCountry;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      selectedCountry = widget.initialValue;
      widget.onChanged(widget.initialValue!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isTile) {
      return ListTile(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              return LanguagePickerListView(
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
        title: lableBuilder(),
      );
    } else {
      return ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return LanguagePickerListView(
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
  }

  Widget lableBuilder() {
    if (widget.labelBuilder != null) {
      return widget.labelBuilder!(selectedCountry);
    }

    if (selectedCountry == null) {
      return const Text('Choose your country');
    } else {
      return Text(langaugeCodeJson[selectedCountry!]!);
    }
  }
}
