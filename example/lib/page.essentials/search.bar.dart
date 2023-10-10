import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class CustomSearchBar extends StatefulWidget {
  const CustomSearchBar({super.key});

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: sizeSm, right: sizeSm),
      height: sizeXl + sizeSm,
      child: Column(
        children: [
          SearchBar(
            // controller: searchController,
            leading: const FaIcon(FontAwesomeIcons.magnifyingGlass),
            hintText: 'Search',
            elevation: const MaterialStatePropertyAll(0),
            backgroundColor: MaterialStatePropertyAll(Theme.of(context).splashColor),
            // side: MaterialStatePropertyAll(BorderSide.),
            padding: const MaterialStatePropertyAll(EdgeInsets.only(left: 8, right: 8)),

            // onSubmitted: (value) => setState(() => searchController.text = value),
          ),
          Expanded(
            child: UserListView(
              // key: ValueKey(searchController.text),
              // searchText: searchController.text,
              field: 'name',
              avatarBuilder: (user) => const Text('Photo'),
              titleBuilder: (user) => Text(user.uid),
              subtitleBuilder: (user) => Text(user.phoneNumber),
              trailingBuilder: (user) => const Icon(Icons.add),
              onTap: (user) => context.pop(user),
            ),
          ),
        ],
      ),
    );
  }
}
