import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/club/widgets/club.details.dart';
import 'package:flutter/material.dart';

class ClubViewScreen extends StatefulWidget {
  static const String routeName = '/Club';
  const ClubViewScreen({super.key, required this.club});

  final Club club;

  @override
  State<ClubViewScreen> createState() => _ClubViewScreenState();
}

class _ClubViewScreenState extends State<ClubViewScreen> {
  final ValueNotifier<int> _tabIndex = ValueNotifier<int>(0);
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.club.name),
          actions: [
            ValueListenableBuilder(
              valueListenable: _tabIndex,
              builder: (_, index, __) {
                if (index == 3 || index == 4) {
                  return OutlinedButton(
                    onPressed: () => ForumService.instance.showPostCreateScreen(
                      context: context,
                      category: widget.club.id + (index == 4 ? '-gallery' : ''),
                    ),
                    child: const Text('글 쓰기'),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            PopupMenuButton<String>(
                icon: const Icon(Icons.menu),
                itemBuilder: (context) {
                  return [
                    const PopupMenuItem(
                      value: Code.edit,
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('소개 화면 수정'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: Code.delete,
                      child: Row(
                        children: [
                          Icon(Icons.delete),
                          SizedBox(width: 8),
                          Text('모임 폐쇄'),
                        ],
                      ),
                    ),
                  ];
                },
                onSelected: (String code) {
                  if (code == Code.edit) {
                    // context.push(ClubEditScreen.routeName, extra: {
                    //   'reference': widget.club.ref,
                    // });
                    ClubService.instance.showUpdateScreen(
                      context: context,
                      club: widget.club,
                    );
                  } else if (code == Code.delete) {
                    //
                  }
                }),
          ],
          bottom: TabBar(
            tabs: const [
              Tab(text: '소개'),
              Tab(text: '일정'),
              Tab(text: '채팅'),
              Tab(text: '게시판'),
              Tab(text: '사진첩'),
            ],
            onTap: (index) {
              _tabIndex.value = index;
            },
          ),
        ),
        body: TabBarView(
          children: [
            ClubDetails(club: widget.club),
            const Text(
                "미팅 시간 날짜 약속 @TODO 간단하게 게시판 형태로 만든다. 날짜를 수동으로 입력한다. 시놀 보고 따라 만든다."),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => FocusScope.of(context).unfocus(),
              child: ChatRoomBody(
                roomId: widget.club.id,
                displayAppBar: false,
                appBarBottomSpacing: 0,
              ),
            ),
            ListTileTheme(
              child: PostListView(
                category: widget.club.id,
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                pageSize: 20,
                separatorBuilder: (p0, p1) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(
                    height: 5,
                    thickness: 1,
                    color: Theme.of(context).colorScheme.outline.withAlpha(64),
                  ),
                ),
                emptyBuilder: () => const Center(child: Text('글을 등록 해 주세요.')),
              ),
            ),
            PostListView.gridView(
              category: '${widget.club.id}-gallery',
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
              itemBuilder: (post, i) => ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: PostCard(post: post),
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              emptyBuilder: () => const Center(child: Text('사진을 등록 해 주세요.')),
            ),
          ],
        ),
      ),
    );
  }
}
