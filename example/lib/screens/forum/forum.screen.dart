import 'package:example/etc/categories.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  static const String routeName = '/Forum';

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen>
    with TickerProviderStateMixin {
  int index = 0;
  late TabController _tabController;

  Iterable<({String? group, String id, String name})> categories =
      Categories.menus.where((v) => v.group == Categories.community);

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: categories.length,
      initialIndex: 0,
      vsync: this,
    );

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        index = _tabController.index;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        listTileTheme: ListTileThemeData(
          titleTextStyle: Theme.of(context).textTheme.labelLarge!.copyWith(
                fontWeight: FontWeight.w700,
              ),
          subtitleTextStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                fontWeight: FontWeight.w400,
              ),
          leadingAndTrailingTextStyle:
              Theme.of(context).textTheme.labelSmall!.copyWith(
                    fontWeight: FontWeight.w300,
                    fontSize: 11,
                  ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('게시판'),
          actions: [
            TextButton.icon(
              onPressed: () {
                ForumService.instance.showPostCreateScreen(
                  context: context,
                  category: categories.elementAt(index).id,
                  group: categories.elementAt(index).group,
                );
              },
              icon: const Icon(
                Icons.create,
                size: 20,
              ),
              label: const Text('글쓰기'),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: categories.map((e) => Tab(text: e.name)).toList(),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: categories
              .map(
                (e) => PostListView(
                  category: e.id,
                  separatorBuilder: (p0, p1) => const Divider(
                    thickness: 0,
                    height: 24,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
