import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class MeetupViewScreen extends StatefulWidget {
  static const String routeName = '/Meetup';
  const MeetupViewScreen({super.key, required this.meetup});

  final Meetup meetup;

  @override
  State<MeetupViewScreen> createState() => _ClubViewScreenState();
}

class _ClubViewScreenState extends State<MeetupViewScreen> {
  final ValueNotifier<int> _tabIndex = ValueNotifier<int>(0);
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        // backgroundColor: Colors.blue,
        appBar: AppBar(
          title: Text(widget.meetup.name),
          actions: [
            MeetupDoc(
              meetup: widget.meetup,
              builder: (meetup) => ValueListenableBuilder(
                valueListenable: _tabIndex,
                builder: (_, index, __) {
                  if (meetup.isMaster && index == 1) {
                    return TextButton(
                      onPressed: () =>
                          MeetupEventService.instance.showCreateScreen(
                        context: context,
                        meetupId: meetup.id,
                      ),
                      child: const Text('일정 생성'),
                    );
                  } else if (meetup.joined && (index == 3 || index == 4)) {
                    return TextButton(
                      onPressed: () =>
                          ForumService.instance.showPostCreateScreen(
                        context: context,
                        category: widget.meetup.id +
                            (index == 4 ? '-club-gallery' : '-club-post'),
                      ),
                      child: const Text('글 쓰기'),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ),
            MeetupDoc(
              meetup: widget.meetup,
              builder: (meetup) => PopupMenuButton<String>(
                  icon: const Icon(Icons.menu),
                  itemBuilder: (context) {
                    return [
                      if (meetup.isMaster)
                        const PopupMenuItem(
                          value: Code.edit,
                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text('모임 정보 수정'),
                            ],
                          ),
                        ),
                      if (meetup.joined)
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
                      if (meetup.isMaster) ...[
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
                      MeetupService.instance.showUpdateScreen(
                        context: context,
                        meetup: widget.meetup,
                      );
                    } else if (code == Code.delete) {
                      await widget.meetup.delete(context: context);
                    } else if (code == Code.leave) {
                      await widget.meetup.leave();
                    } else if (code == Code.join) {
                      await widget.meetup.join();
                    } else if (code == Code.reminders) {
                      final text = await input(
                        context: context,
                        initialValue: meetup.reminder,
                        title: 'Reminder',
                        hintText: 'Input reminder',
                        minLines: 2,
                        maxLines: 5,
                      );
                      if (text != null) {
                        await meetup.update(reminder: text);
                      }
                    }
                  }),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: T.info.tr),
              Tab(text: T.event.tr),
              Tab(text: T.chat.tr),
              Tab(text: T.notice.tr),
              Tab(text: T.gallery.tr),
            ],
            onTap: (index) {
              _tabIndex.value = index;
            },
          ),
        ),
        body: TabBarView(
          children: [
            MeetupDetails(meetup: widget.meetup),
            MeetupEventListView(
              meetup: widget.meetup,
              separatorBuilder: (p0, p1) => const Divider(height: 16),
              emptyBuilder: () => const Center(
                child: Text('일정이 없습니다.'),
              ),
            ),
            MeetupDoc(
              meetup: widget.meetup,
              builder: (meetup) => meetup.users.contains(myUid)
                  ? GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => FocusScope.of(context).unfocus(),
                      child: ChatRoomBody(
                        roomId: widget.meetup.id,
                        displayAppBar: false,
                        appBarBottomSpacing: 0,
                      ),
                    )
                  : MeetupViewRegisterFirstButton(
                      meetup: meetup,
                      label: "모임에 가입하셔야\n채팅방을 볼 수 있습니다.",
                    ),
            ),
            MeetupDoc(
              meetup: widget.meetup,
              builder: (meetup) => meetup.users.contains(myUid)
                  ? ListTileTheme(
                      child: PostListView(
                        category: '${widget.meetup.id}-club-post',
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
                        emptyBuilder: () => const Center(
                          child: Text('글을 등록 해 주세요.'),
                        ),
                      ),
                    )
                  : MeetupViewRegisterFirstButton(
                      meetup: meetup,
                      label: "모임에 가입하셔야\n게시판을 볼 수 있습니다.",
                    ),
            ),
            MeetupDoc(
              meetup: widget.meetup,
              builder: (meetup) => meetup.users.contains(myUid)
                  ? PostListView.gridView(
                      category: '${widget.meetup.id}-club-gallery',
                      padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                      itemBuilder: (post, i) => ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: PostCard(
                          post: post,
                          displayAvatar: true,
                          displaySubtitle: true,
                        ),
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        mainAxisExtent: 240,
                      ),
                      emptyBuilder: () => const Center(
                        child: Text('사진을 등록 해 주세요.'),
                      ),
                    )
                  : MeetupViewRegisterFirstButton(
                      meetup: meetup,
                      label: "모임에 가입하셔야\n사진첩을 볼 수 있습니다.",
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
