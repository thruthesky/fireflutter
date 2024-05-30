import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class MeetupViewScreen extends StatefulWidget {
  static const String routeName = '/Meetup';
  const MeetupViewScreen({super.key, required this.meetup});

  final Meetup meetup;

  @override
  State<MeetupViewScreen> createState() => _MeetupViewScreenState();
}

class _MeetupViewScreenState extends State<MeetupViewScreen> {
  final ValueNotifier<int> _tabIndex = ValueNotifier<int>(0);
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
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
                      child: Text(T.createMeetupEvent.tr),
                    );
                  } else if (meetup.joined && (index == 3 || index == 4)) {
                    return TextButton(
                      onPressed: () =>
                          ForumService.instance.showPostCreateScreen(
                        context: context,
                        category: widget.meetup.id +
                            (index == 4 ? '-meetup-gallery' : '-meetup-post'),
                      ),
                      child: Text(T.createNotice.tr),
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
                        PopupMenuItem(
                          value: Code.edit,
                          child: Row(
                            children: [
                              const Icon(Icons.edit),
                              const SizedBox(width: 8),
                              Text(T.editMeetupInformation.tr),
                            ],
                          ),
                        ),
                      if (meetup.joined)
                        PopupMenuItem(
                          value: Code.leave,
                          child: Row(
                            children: [
                              const Icon(Icons.logout),
                              const SizedBox(width: 8),
                              Text(T.leaveMeetup.tr),
                            ],
                          ),
                        )
                      else
                        PopupMenuItem(
                          value: Code.join,
                          child: Row(
                            children: [
                              const Icon(Icons.how_to_reg),
                              const SizedBox(width: 8),
                              Text(T.joinMeetup.tr),
                            ],
                          ),
                        ),
                      if (meetup.isMaster) ...[
                        const PopupMenuDivider(),
                        PopupMenuItem(
                          value: Code.reminders,
                          child: Row(
                            children: [
                              const Icon(Icons.newspaper),
                              const SizedBox(width: 8),
                              Text(T.noticeManage.tr),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: Code.delete,
                          child: Row(
                            children: [
                              const Icon(Icons.close),
                              const SizedBox(width: 8),
                              Text(T.closeMeetup.tr),
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
                      final deleted =
                          await widget.meetup.delete(context: context);
                      if (deleted == true) {
                        Navigator.of(context).pop();
                      }
                    } else if (code == Code.leave) {
                      await widget.meetup.leave();
                    } else if (code == Code.join) {
                      await widget.meetup.join();
                    } else if (code == Code.reminders) {
                      final text = await input(
                        context: context,
                        initialValue: meetup.reminder,
                        title: T.reminder.tr,
                        hintText: T.inputReminder.tr,
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
              emptyBuilder: () => Center(
                child: Text(T.noEvent.tr),
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
                      label: T.joinMeetupToChat.tr,
                    ),
            ),
            MeetupDoc(
              meetup: widget.meetup,
              builder: (meetup) => meetup.users.contains(myUid)
                  ? ListTileTheme(
                      child: PostListView(
                        category: '${widget.meetup.id}-meetup-post',
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
                        emptyBuilder: () => Center(
                          child: Text(T.noNoticeYet.tr),
                        ),
                      ),
                    )
                  : MeetupViewRegisterFirstButton(
                      meetup: meetup,
                      label: T.joinMeetupToViewNotice.tr,
                    ),
            ),
            MeetupDoc(
              meetup: widget.meetup,
              builder: (meetup) => meetup.users.contains(myUid)
                  ? PostListView.gridView(
                      category: '${widget.meetup.id}-meetup-gallery',
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
                      emptyBuilder: () => Center(
                        child: Text(T.uploadPhoto.tr),
                      ),
                    )
                  : MeetupViewRegisterFirstButton(
                      meetup: meetup,
                      label: T.joinMeetupToViewGallery.tr,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
