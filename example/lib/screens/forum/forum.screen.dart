import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class Categories {
  static String qna = 'qna';
  static String discussion = 'discussion';
  static String buyandsell = 'buyandsell';
  static String info = 'info';

  Categories._();

  static List<({String name, String id})> menus = [
    (name: '토론', id: discussion),
    (name: '질문', id: qna),
    (name: '장터', id: buyandsell),
    (name: '정보', id: info),
  ];

  static String name(String id) {
    for (final menu in menus) {
      if (menu.id == id) {
        return menu.name;
      }
    }
    return '';
  }
}

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

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: Categories.menus.length,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('게시판'),
        actions: [
          TextButton.icon(
            onPressed: () {
              ForumService.instance.showPostCreateScreen(
                context: context,
                category: Categories.menus[index].id,
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
          tabs: Categories.menus.map((e) => Tab(text: e.name)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: Categories.menus
            .map(
              (e) => PostListView(
                category: e.id,
              ),
            )
            .toList(),
      ),
    );
  }
}
