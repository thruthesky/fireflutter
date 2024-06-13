import 'package:easystate/easystate.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:typesense/typesense.dart';
import 'package:example/keys.dart';

class ForumSearchState with ChangeNotifier {
  List<dynamic> data = [];
  void setData(hits) {
    for (var documents in hits) {
      data.add(documents["document"]);
    }
    notifyListeners();
  }
}

class ForumSearchScreen extends StatefulWidget {
  static const String routeName = '/ForumSearch';
  const ForumSearchScreen({super.key});

  @override
  State<ForumSearchScreen> createState() => _ForumSearchScreenState();
}

class _ForumSearchScreenState extends State<ForumSearchScreen> {
  final searchController = TextEditingController();
  final searchCategoryController = TextEditingController();
  final searchGroupController = TextEditingController();
  final searchFieldController = TextEditingController();
  final searchDataTypeController = TextEditingController();

  final searchOptions = {
    'category': 'all',
    'group': 'all',
    'field': 'all',
    'dataType': 'all'
  };

  Map<String, String> categories = {
    'all': 'All',
    'qna': 'Qna',
    'discussion': 'Discussion',
    'buyandsell': 'BuyAndSell',
    'info': 'Info'
  };

  Map<String, String> groups = {
    'all': 'All',
    'community': 'Community',
    'meetup': 'Meetup'
  };

  Map<String, String> fields = {
    'all': 'All',
    'title': 'Title',
    'content': 'Content'
  };

  Map<String, String> dataTypes = {
    'all': 'All',
    'title': 'Post',
    'content': 'Comment'
  };

  Client client = Client(Configuration(
    typesenseApiKey,
    nodes: {
      Node(Protocol.https, typesenseHost, port: 443),
    },
  ));

  @override
  void initState() {
    super.initState();
    
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  final ValueNotifier<String> searchChanges = ValueNotifier('');
  @override
  Widget build(BuildContext _) {
    return EasyState(
      state: ForumSearchState(),
      child: Builder(
        builder: (context) {
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
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Category',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall,
                                    ),
                                    Text(
                                      categories[searchOptions['category']]!,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    )
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Group',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall,
                                    ),
                                    Text(
                                      groups[searchOptions['group']]!,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Field',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall,
                                    ),
                                    Text(
                                      fields[searchOptions['field']]!,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Data',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall,
                                    ),
                                    Text(
                                      dataTypes[searchOptions['dataType']]!,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              const SizedBox(width: 8),
                              Builder(
                                builder: (_) => ElevatedButton.icon(
                                  onPressed: () {
                                    Scaffold.of(_).openEndDrawer();

                                    FocusScope.of(context).unfocus();
                                  },
                                  label: const Text('Filter'),
                                  icon: const Icon(Icons.filter_list_outlined),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
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
                                      onPressed: () => onSearch(context),
                                    );
                            },
                          ),
                        ),
                        onChanged: (v) => searchChanges.value = v,
                        onSubmitted: (value) => onSearch(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            endDrawer: Drawer(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Search Filter',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 16),
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
                                      onPressed: () => {
                                        onSearch(context),
                                        Navigator.pop(context)
                                      },
                                    );
                            },
                          ),
                        ),
                        onChanged: (v) => searchChanges.value = v,
                        onSubmitted: (value) => onSearch(context),
                      ),
                      const SizedBox(height: 16),
                      const Text('Search by categories'),
                      DropdownMenu<String>(
                        initialSelection: searchOptions['category'],
                        controller: searchCategoryController,
                        onSelected: (String? v) {
                          searchOptions['category'] = v!;
                        },
                        dropdownMenuEntries: categories.entries
                            .map<DropdownMenuEntry<String>>(
                                (MapEntry<String, String> v) {
                          return DropdownMenuEntry<String>(
                            value: v.key,
                            label: v.value,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      const Text('Search by group'),
                      DropdownMenu<String>(
                        initialSelection: searchOptions['group'],
                        controller: searchGroupController,
                        onSelected: (String? v) {
                          searchOptions['group'] = v!;
                        },
                        dropdownMenuEntries: groups.entries
                            .map<DropdownMenuEntry<String>>(
                                (MapEntry<String, String> v) {
                          return DropdownMenuEntry<String>(
                            value: v.key,
                            label: v.value,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      const Text('Search by field'),
                      DropdownMenu<String>(
                        initialSelection: searchOptions['field'],
                        controller: searchFieldController,
                        onSelected: (String? v) {
                          searchOptions['field'] = v!;
                        },
                        dropdownMenuEntries: fields.entries
                            .map<DropdownMenuEntry<String>>(
                                (MapEntry<String, String> v) {
                          return DropdownMenuEntry<String>(
                            value: v.key,
                            label: v.value,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      const Text('Search by data type'),
                      DropdownMenu<String>(
                        initialSelection: searchOptions['dataType'],
                        controller: searchDataTypeController,
                        onSelected: (String? v) {
                          searchOptions['dataType'] = v!;
                        },
                        dropdownMenuEntries: dataTypes.entries
                            .map<DropdownMenuEntry<String>>(
                                (MapEntry<String, String> v) {
                          return DropdownMenuEntry<String>(
                            value: v.key,
                            label: v.value,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              searchOptions['category'] = 'all';
                              searchOptions['group'] = 'all';
                              searchOptions['field'] = 'all';
                              searchOptions['dataType'] = 'all';
                              setState(() {});
                            },
                            child: const Text('Reset'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {});

                              debugPrint(searchCategoryController.value.text);
                              debugPrint(searchGroupController.value.text);
                              debugPrint(searchFieldController.value.text);
                              debugPrint(searchDataTypeController.value.text);

                              Navigator.pop(context);
                              FocusScope.of(context).unfocus();
                              onSearch(context);
                            },
                            child: const Text('Search'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16)
                    ],
                  ),
                ),
              ),
            ),
            body: EasyStateBuilder<ForumSearchState>(
              builder: (context, state) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.data.length,
                  itemBuilder: (c, i) {
                    final data = state.data[i];
                    if (data['commentId'] != null) {
                      return CommentContent(
                        comment: Comment.fromJson(data, data['commentId'],
                            postId: data['postId']),
                      );
                    } else {
                      return PostListTile(
                        post: Post.fromJson(
                          data,
                          id: data['postId'],
                          category: data['category'],
                        ),
                      );
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  onSearch(context) async {
    debugPrint('searching for ${searchController.text}');

    final searchParameters = {
      'q': getSearchString(),
      'query_by': getQueryBy(),
      'filter_by': getFilterBy(),
      'sort_by': 'createdAt:desc',
      'page': "1"
    };
    debugPrint(searchParameters.toString());
    final res = await client
        .collection(typesenseForumCollection)
        .documents
        .search(searchParameters);

    EasyState.of<ForumSearchState>(context).setData(res['hits']);
  }

  getSearchString() {
    if (searchController.text.isEmpty) {
      return '*';
    } else {
      return searchController.text;
    }
  }

  getQueryBy() {
    if (searchOptions['field'] == 'title') {
      return 'title';
    } else if (searchOptions['field'] == 'content') {
      return 'content';
    } else {
      return 'title,content';
    }
  }

  getFilterBy() {
    List<String> filters = [];

    if (searchOptions['category'] != 'all') {
      filters.add('category:${searchOptions['category']}');
    }

    if (searchOptions['group'] != 'all') {
      filters.add('group:${searchOptions['group']}');
    }

    /// determine either post or comment
    // if (searchOptions['dataType'] != 'all') {
    //   filters.add('dataType:${searchOptions['dataType']}');
    // }

    if (filters.isEmpty) {
      return '';
    }
    debugPrint(filters.join(' && '));
    return filters.join(' && ');
  }
}
