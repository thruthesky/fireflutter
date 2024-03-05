import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class LanguagePickerListView extends StatefulWidget {
  const LanguagePickerListView({
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
  final Widget Function(MapEntry)? itemBuilder;
  final void Function(String) onChanged;

  @override
  State<LanguagePickerListView> createState() => _LanguagePickerListViewState();
}

class _LanguagePickerListViewState extends State<LanguagePickerListView> {
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.headerBuilder?.call() ?? const Text('Language Picker'),
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
          children: langaugeCodeJson.entries
              .where((e) =>
                  widget.filters == null || widget.filters!.contains(e.key))
              .where((e) =>
                  e.key == searchController.text ||
                  e.value
                      .toLowerCase()
                      .contains(searchController.text.toLowerCase()))
              .map(
                (e) => InkWell(
                  onTap: () {
                    widget.onChanged(e.key);
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: widget.itemBuilder?.call(e) ??
                        Text(
                          '  ${e.value} ',
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
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
