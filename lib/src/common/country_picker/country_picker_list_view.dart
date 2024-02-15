import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class CountryPickerListView extends StatefulWidget {
  const CountryPickerListView({
    super.key,
    this.filters,
    required this.search,
    this.headerBuilder,
    required this.onChanged,
  });

  /// List of country codes to show in the list.
  final List<String>? filters;
  final bool search;
  final Widget Function()? headerBuilder;
  final void Function(Map<String, String>) onChanged;

  @override
  State<CountryPickerListView> createState() => _CountryPickerListViewState();
}

class _CountryPickerListViewState extends State<CountryPickerListView> {
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    print("search: ${searchController.text}");
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.headerBuilder?.call() ?? const Text('Country Picker'),
          if (widget.search)
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
      ),
      content: Container(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: countryPickerList(searchController.text)
                .where((e) =>
                    widget.filters == null ||
                    widget.filters!.contains(e['code']))
                .map(
                  (e) => InkWell(
                    onTap: () {
                      widget.onChanged(e);
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        children: [
                          Text(
                            '${e['flag']}',
                            style: TextStyle(
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .displaySmall!
                                  .fontSize,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '  ${e['name']} ',
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
                          // Text(
                          //   ' (${e['code']})',
                          //   style: TextStyle(
                          //     color: Theme.of(context).colorScheme.secondary,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}


///
///
/*SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Country Picker'),
            ...countryPickerList()
                .where((e) => filters == null || filters!.contains(e['code']))
                .map(
                  (e) => InkWell(
                    onTap: () {
                      onChanged(e);
                      Navigator.pop(context);
                    },
                    child: Row(
                      children: [
                        Text(
                          '${e['flag']}',
                          style: TextStyle(
                            fontSize: Theme.of(context)
                                .textTheme
                                .displaySmall!
                                .fontSize,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '  ${e['name']} ',
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
                        // Text(
                        //   ' (${e['code']})',
                        //   style: TextStyle(
                        //     color: Theme.of(context).colorScheme.secondary,
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ],
        ),
      ),*/