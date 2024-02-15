import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class CountryPickerListView extends StatefulWidget {
  const CountryPickerListView({
    super.key,
    this.filters,
    required this.search,
    this.headerBuilder,
    this.itemBuilder,
    required this.onChanged,
  });

  /// List of country codes to show in the list.
  final List<String>? filters;
  final bool search;
  final Widget Function()? headerBuilder;
  final Widget Function(CountryCode)? itemBuilder;
  final void Function(CountryCode) onChanged;

  @override
  State<CountryPickerListView> createState() => _CountryPickerListViewState();
}

class _CountryPickerListViewState extends State<CountryPickerListView> {
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.headerBuilder?.call() ?? const Text('Country Picker'),
          if (widget.search) ...[
            const SizedBox(height: 8),
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: countryList(searchController.text)
              .where((e) =>
                  widget.filters == null || widget.filters!.contains(e.alpha2))
              .map(
                (e) => InkWell(
                  onTap: () {
                    widget.onChanged(e);
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: widget.itemBuilder?.call(e) ??
                        Row(
                          children: [
                            Text(
                              e.flag,
                              style: TextStyle(
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .displaySmall!
                                    .fontSize,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '  ${e.officialName} ',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .fontSize,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
