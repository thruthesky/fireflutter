import 'package:flutter/material.dart';

class ForumSearchScreen extends StatefulWidget {
  static const String routeName = '/ForumSearch';
  const ForumSearchScreen({super.key});

  @override
  State<ForumSearchScreen> createState() => _ForumSearchScreenState();
}

class _ForumSearchScreenState extends State<ForumSearchScreen> {
  final searchController = TextEditingController();

  final ValueNotifier<String> searchChanges = ValueNotifier('');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forum Search'),
        toolbarHeight: 120,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            child: Column(
              children: [
                const Text(
                    'Search categories: all, qna, discussion, buyandsell, info'),
                const Text('Search by grouop: community, meetup,'),
                const Text('Search by field: All, title only, content only,'),
                const Text('Search by data type: all, post only, comment only'),
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: '검색어를 입력하세요',
                    prefixIcon: IconButton(
                      icon: ValueListenableBuilder(
                        valueListenable: searchChanges,
                        builder: (context, value, child) {
                          return Icon(
                            value.isEmpty ? Icons.search : Icons.clear,
                          );
                        },
                      ),
                      onPressed: () {
                        searchController.clear();
                        searchChanges.value = '';
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: ValueListenableBuilder(
                      valueListenable: searchChanges,
                      builder: (context, value, child) {
                        return value.isEmpty
                            ? const SizedBox.shrink()
                            : IconButton(
                                icon: const Icon(Icons.send),
                                onPressed: () => onSearch(),
                              );
                      },
                    ),
                  ),
                  onChanged: (v) => searchChanges.value = v,
                  onSubmitted: (value) => onSearch(),
                ),
              ],
            ),
          ),
        ),
      ),
      body: const Column(
        children: [
          Text("ForumSearch"),
        ],
      ),
    );
  }

  onSearch() {
    print('searching for ${searchController.text}');
  }
}
