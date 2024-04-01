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
            ClubDoc(
              club: widget.club,
              builder: (club) => ValueListenableBuilder(
                valueListenable: _tabIndex,
                builder: (_, index, __) {
                  if (club.isMaster && index == 1) {
                    return OutlinedButton(
                      onPressed: () => {},
                      child: const Text('일정 생성'),
                    );
                  } else if (club.joined && (index == 3 || index == 4)) {
                    return OutlinedButton(
                      onPressed: () =>
                          ForumService.instance.showPostCreateScreen(
                        context: context,
                        category:
                            widget.club.id + (index == 4 ? '-gallery' : ''),
                      ),
                      child: const Text('글 쓰기'),
                    );
                  } else
                    return const SizedBox.shrink();
                },
              ),
            ),
            ClubDoc(
              club: widget.club,
              builder: (club) => PopupMenuButton<String>(
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
                      if (club.joined)
                        const PopupMenuItem(
                          value: Code.leave,
                          child: Row(
                            children: [
                              Icon(Icons.logout),
                              SizedBox(width: 8),
                              Text('모임 탈퇴'),
                            ],
                          ),
                        )
                      else
                        const PopupMenuItem(
                          value: Code.join,
                          child: Row(
                            children: [
                              Icon(Icons.how_to_reg),
                              SizedBox(width: 8),
                              Text('모임 가입'),
                            ],
                          ),
                        ),
                      if (club.isMaster) ...[
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: Code.reminders,
                          child: Row(
                            children: [
                              Icon(Icons.newspaper),
                              SizedBox(width: 8),
                              Text('공지사항 관리'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: Code.delete,
                          child: Row(
                            children: [
                              Icon(Icons.close),
                              SizedBox(width: 8),
                              Text('모임 폐쇄'),
                            ],
                          ),
                        ),
                      ],
                    ];
                  },
                  onSelected: (String code) async {
                    if (code == Code.edit) {
                      ClubService.instance.showUpdateScreen(
                        context: context,
                        club: widget.club,
                      );
                    } else if (code == Code.delete) {
                      //
                    } else if (code == Code.leave) {
                      await widget.club.leave();
                    } else if (code == Code.join) {
                      await widget.club.join();
                    } else if (code == Code.reminders) {
                      final text = await input(
                        context: context,
                        initialValue: club.reminder,
                        title: 'Reminder',
                        hintText: 'Input reminder',
                        minLines: 2,
                        maxLines: 5,
                      );
                      if (text != null) {
                        await club.update(reminder: text);
                      }
                    }
                  }),
            ),
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
            ClubDoc(
              club: widget.club,
              builder: (club) => club.users.contains(myUid)
                  ? GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => FocusScope.of(context).unfocus(),
                      child: ChatRoomBody(
                        roomId: widget.club.id,
                        displayAppBar: false,
                        appBarBottomSpacing: 0,
                      ),
                    )
                  : ClubViewRegisterFirst(
                      club: club,
                      label: "모임에 가입하셔야\n채팅방을 볼 수 있습니다.",
                    ),
            ),
            ClubDoc(
              club: widget.club,
              builder: (club) => club.users.contains(myUid)
                  ? ListTileTheme(
                      child: PostListView(
                        category: widget.club.id,
                        padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                        pageSize: 20,
                        separatorBuilder: (p0, p1) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Divider(
                            height: 5,
                            thickness: 1,
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withAlpha(64),
                          ),
                        ),
                        emptyBuilder: () =>
                            const Center(child: Text('글을 등록 해 주세요.')),
                      ),
                    )
                  : ClubViewRegisterFirst(
                      club: club,
                      label: "모임에 가입하셔야\n게시판을 볼 수 있습니다.",
                    ),
            ),
            ClubDoc(
              club: widget.club,
              builder: (club) => club.users.contains(myUid)
                  ? PostListView.gridView(
                      category: '${widget.club.id}-gallery',
                      padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                      itemBuilder: (post, i) => ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: PostCard(post: post),
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      emptyBuilder: () =>
                          const Center(child: Text('사진을 등록 해 주세요.')),
                    )
                  : ClubViewRegisterFirst(
                      club: club,
                      label: "모임에 가입하셔야\n사진첩을 볼 수 있습니다.",
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
