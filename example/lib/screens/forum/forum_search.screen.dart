import 'package:cached_network_image/cached_network_image.dart';
import 'package:example/screens/forum/forum.screen.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:typesense/typesense.dart';

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

  List<dynamic> forumData = [];

  Map<String, dynamic> searchParameters = {};
  int page = 1;
  int limit = 10;
  bool hasMore = true;
  bool noResultFound = false;
  bool isloading = false;

  final searchOptions = {
    Code.category: Code.all,
    Code.group: Code.all,
    Code.field: Code.all,
    Code.dataType: Code.all
  };

  Map<String, String> categories = {
    Code.all: T.all.tr,
    Categories.qna: Categories.name(Categories.qna),
    Categories.discussion: Categories.name(Categories.discussion),
    Categories.buyandsell: Categories.name(Categories.buyandsell),
    Categories.info: Categories.name(Categories.info)
  };

  Map<String, String> groups = {
    Code.all: T.all.tr,
    Code.community: T.community.tr,
    Code.meetup: T.meetup.tr
  };

  Map<String, String> fields = {
    Code.all: T.all.tr,
    Code.title: T.title.tr,
    Code.content: T.content.tr
  };

  Map<String, String> dataTypes = {
    Code.all: T.all.tr,
    Code.posts: T.posts.tr,
    Code.comments: T.comments.tr
  };

  Client client = Client(Configuration(
    "typesenseApiKey",
    nodes: {
      Node(Protocol.https, "typesenseHost", port: 443),
    },
  ));

  @override
  void initState() {
    super.initState();
    onSearch();
  }

  @override
  void dispose() {
    searchController.dispose();
    searchCategoryController.dispose();
    searchGroupController.dispose();
    searchFieldController.dispose();
    searchDataTypeController.dispose();
    super.dispose();
  }

  final ValueNotifier<String> searchChanges = ValueNotifier('');
  @override
  Widget build(BuildContext _) {
    return Scaffold(
      appBar: AppBar(
        title: Text(T.forumSearch.tr),
        toolbarHeight: 120,
        actions: const [SizedBox.shrink()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: T.searchKeywordHint.tr,
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
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8, right: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PopupMenuButton(
                      initialValue: searchOptions['category'],
                      position: PopupMenuPosition.under,
                      onSelected: (v) {
                        searchOptions['category'] = v;
                        onSearch();
                      },
                      itemBuilder: (c) => categories.entries
                          .map((v) => PopupMenuItem(
                                value: v.key,
                                child: Text(v.value),
                              ))
                          .toList(),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              T.category.tr,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            Text(
                              categories[searchOptions['category']]!,
                              style: Theme.of(context).textTheme.bodySmall,
                            )
                          ],
                        ),
                      ),
                    ),
                    PopupMenuButton(
                      initialValue: searchOptions['group'],
                      position: PopupMenuPosition.under,
                      onSelected: (v) {
                        searchOptions['group'] = v;
                        onSearch();
                      },
                      itemBuilder: (c) => groups.entries
                          .map((v) => PopupMenuItem(
                                value: v.key,
                                child: Text(v.value),
                              ))
                          .toList(),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              T.group.tr,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            Text(
                              groups[searchOptions['group']]!,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                    PopupMenuButton(
                      initialValue: searchOptions['field'],
                      position: PopupMenuPosition.under,
                      onSelected: (v) {
                        searchOptions['field'] = v;
                        onSearch();
                      },
                      itemBuilder: (c) => fields.entries
                          .map((v) => PopupMenuItem(
                                value: v.key,
                                child: Text(v.value),
                              ))
                          .toList(),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              T.field.tr,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            Text(
                              fields[searchOptions['field']]!,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                    PopupMenuButton(
                      initialValue: searchOptions['dataType'],
                      position: PopupMenuPosition.under,
                      onSelected: (v) {
                        searchOptions['dataType'] = v;
                        onSearch();
                      },
                      itemBuilder: (c) => dataTypes.entries
                          .map((v) => PopupMenuItem(
                                value: v.key,
                                child: Text(v.value),
                              ))
                          .toList(),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              T.forumType.tr,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            Text(
                              dataTypes[searchOptions['dataType']]!,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Builder(
                      builder: (context) => IconButton(
                        onPressed: () {
                          Scaffold.of(context).openEndDrawer();
                          FocusScope.of(context).unfocus();
                        },
                        icon: const Icon(Icons.filter_list_outlined),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
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
                Text(T.searchFilter.tr,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: T.searchKeywordHint.tr,
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
                                onPressed: () =>
                                    {onSearch(), Navigator.pop(context)},
                              );
                      },
                    ),
                  ),
                  onChanged: (v) => searchChanges.value = v,
                  onSubmitted: (value) => onSearch(),
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
                        onSearch();
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
      body: isloading
          ? const Center(child: CircularProgressIndicator())
          : noResultFound
              ? SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              const Icon(Icons.search, size: 64),
                              Text(T.noResultFound.tr),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  padding: const EdgeInsets.all(16),
                  itemCount: forumData.length,
                  itemBuilder: (c, i) {
                    if (hasMore && i + 1 == forumData.length) {
                      /// get more data
                      fetchMore();
                    }

                    final json = forumData[i];
                    if (json['commentId'] != null) {
                      return InkWell(
                        onTap: () async {
                          Post? post = await Post.get(
                              category: json['category'], id: json['postId']);
                          if (post != null && mounted) {
                            ForumService.instance.showPostViewScreen(
                                context: context, post: post);
                          }
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const SizedBox(width: 16),
                                    Text(
                                      '${T.forum.tr}:',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge,
                                    ),
                                    Text(
                                      json['collection'] == 'posts'
                                          ? T.post.tr
                                          : T.comment.tr,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${T.category.tr}:',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge,
                                    ),
                                    Text(
                                      Categories.name(json['category']),
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                FutureBuilder<Post?>(
                                  future: Post.get(
                                      category: json['category'],
                                      id: json['postId']),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const SizedBox(height: 40);
                                    }
                                    Post? post = snapshot.data;

                                    if (post == null) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            left: 16, right: 16, bottom: 16),
                                        child: ListTile(
                                            title: Text(
                                                T.postDeletedOrNotFound.tr)),
                                      );
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16.0, right: 16.0, bottom: 16),
                                      child: PostCard(
                                        post: post,
                                        displayAvatar: true,
                                        displaySubtitle: true,
                                      ),
                                    );
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 24),
                                  child: CommentListTile(
                                    comment: Comment.fromJson(
                                        json, json['commentId'],
                                        postId: json['postId']),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    } else {
                      Post post = Post.fromJson(
                        json,
                        id: json['postId'],
                        category: json['category'],
                      );
                      return InkWell(
                        onTap: () async {
                          if (mounted) {
                            ForumService.instance.showPostViewScreen(
                                context: context, post: post);
                            FocusManager.instance.primaryFocus?.unfocus();
                          }
                        },
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const SizedBox(width: 16),
                                    Text(
                                      '${T.forum.tr}:',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge,
                                    ),
                                    Text(
                                      json['collection'] == 'posts'
                                          ? T.post.tr
                                          : T.comment.tr,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${T.category.tr}:',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge,
                                    ),
                                    Text(
                                      Categories.name(json['category']),
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                ListTileTheme(
                                  child: PostListTile(
                                    post: post,
                                  ),
                                ),
                                if (post.urls.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: InkWell(
                                      onTap: () {
                                        showGeneralDialog(
                                          context: context,
                                          pageBuilder: (_, __, ___) =>
                                              PhotoViewerScreen(
                                            urls: post.urls,
                                          ),
                                        );

                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                      },
                                      child: Column(
                                        children: [
                                          ...post.urls.map((v) =>
                                              CachedNetworkImage(imageUrl: v)),
                                        ],
                                      ),
                                    ),
                                  )
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
    );
  }

  // get next page by increasing the page number and search again.
  // without resetting current data.
  fetchMore() {
    page = page + 1;
    onSearch(reset: false);
  }

  // search data from typesense base on the search parameters
  // `reset` is set by default to true. it reset the forumData to display new list.
  // To add new data to forumData set `reset` to false so it will not clear forumData.
  onSearch({bool reset = true}) async {
    // clear forumData, reset page, and set noResults to false
    if (reset) {
      forumData.clear();
      page = 1;
      hasMore = true;
      noResultFound = false;
      isloading = true;
      setState(() {});
    }
    searchParameters = {
      'q': getSearchString(),
      'query_by': getQueryBy(),
      'filter_by': getFilterBy(),
      'sort_by': 'createdAt:desc',
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final res = await client
        .collection("typesenseForumCollection")
        .documents
        .search(searchParameters);
    final hits = res['hits'];

    // if the hit is less than the limit no more data to fetch
    if (hits.isEmpty || hits.length < limit) {
      hasMore = false;
    }

    // display no result message if no results found and forumData is empty
    if (hits.isEmpty && forumData.isEmpty) {
      noResultFound = true;
    }
    for (var documents in hits) {
      forumData.add(documents["document"]);
    }
    isloading = false;
    setState(() {});
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

    if (searchOptions['dataType'] != 'all') {
      filters.add('collection:${searchOptions['dataType']}');
    }

    // filter deleted posts/comments
    filters.add('deleted:!=true');

    debugPrint(filters.join(' && '));
    return filters.join(' && ');
  }
}
