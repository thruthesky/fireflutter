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
                  if (index == 0 &&
                      meetup.joined == false &&
                      meetup.blocked == false) {
                    return MeetupJoinButton(meetup: meetup);
                  }
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
                            (index == 4
                                ? Code.meetupGalleryCategoryPostFix
                                : Code.meetupPostCategoryPostFix),
                        group: 'meetup',
                      ),
                      child: Text(
                          index == 4 ? T.addPhoto.tr : T.createMeetupPost.tr),
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
                      if (isAdmin)
                        PopupMenuItem(
                          value: Code.meetupAdminSettings,
                          child: Row(
                            children: [
                              const Icon(Icons.grade),
                              const SizedBox(width: 8),
                              Text(T.meetupAdminSetting.tr),
                            ],
                          ),
                        ),
                      if (meetup.blocked == false)
                        PopupMenuItem(
                          value: Code.members,
                          child: Row(
                            children: [
                              const Icon(Icons.people_alt_outlined),
                              const SizedBox(width: 8),
                              Text(T.members.tr),
                            ],
                          ),
                        ),
                      if (meetup.isMaster) ...[
                        PopupMenuItem(
                          value: Code.blockUser,
                          child: Row(
                            children: [
                              const Icon(Icons.block_rounded),
                              const SizedBox(width: 8),
                              Text(T.blockedMembers.tr),
                            ],
                          ),
                        ),
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
                      ],
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
                      else if (meetup.blocked == false)
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
                      PopupMenuItem(
                        value: Code.chat,
                        child: Row(
                          children: [
                            const Icon(Icons.chat),
                            const SizedBox(width: 8),
                            Text(T.contact.tr),
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
                    } else if (code == Code.members) {
                      MeetupService.instance.showMembersScreen(
                        context: context,
                        meetup: widget.meetup,
                      );
                    } else if (code == Code.blockUser) {
                      MeetupService.instance.showBlockedMembersScreen(
                        context: context,
                        meetup: widget.meetup,
                      );
                    } else if (code == Code.delete) {
                      final deleted =
                          await widget.meetup.delete(context: context);
                      if (deleted == true) {
                        Navigator.of(context).pop();
                      }
                    } else if (code == Code.chat) {
                      ChatService.instance.showChatRoomScreen(
                        context: context,
                        otherUid: meetup.master,
                      );
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
                    } else if (code == Code.meetupAdminSettings) {
                      AdminService.instance.showMeetupSettingScreen(
                        context: context,
                        meetup: widget.meetup,
                      );
                    }
                  }),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: T.info.tr),
              Tab(text: T.event.tr),
              Tab(text: T.chat.tr),
              Tab(text: T.forum.tr),
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
              padding: const EdgeInsets.all(16),
              separatorBuilder: (p0, p1) => const SizedBox(height: 8),
              emptyBuilder: () => Center(
                child: Card(
                    margin: const EdgeInsets.all(24),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(T.noEvent.tr),
                    )),
              ),
            ),
            MeetupDoc(
              meetup: widget.meetup,
              builder: (meetup) {
                if (meetup.users.contains(myUid)) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => FocusScope.of(context).unfocus(),
                    child: ChatRoomBody(
                      roomId: widget.meetup.id,
                      displayAppBar: false,
                      appBarBottomSpacing: 0,
                    ),
                  );
                } else if (meetup.blocked == true) {
                  return MeetupViewBlocked(
                    meetup: meetup,
                    label: T.meetupChatBlocked.tr,
                  );
                } else {
                  return MeetupViewRegisterFirstButton(
                    meetup: meetup,
                    label: T.joinMeetupToChat.tr,
                  );
                }
              },
            ),
            MeetupDoc(
                meetup: widget.meetup,
                builder: (meetup) {
                  if (meetup.users.contains(myUid)) {
                    return PostListView(
                      category: '${widget.meetup.id}${Code.meetupPostCategoryPostFix}',
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
                        child: Card(
                            margin: const EdgeInsets.all(24),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Text(T.noNoticeYet.tr),
                            )),
                      ),
                    );
                  } else if (meetup.blocked == true) {
                    return MeetupViewBlocked(
                      meetup: meetup,
                      label: T.meetupViewNoticeBlocked.tr,
                    );
                  } else {
                    return MeetupViewRegisterFirstButton(
                      meetup: meetup,
                      label: T.joinMeetupToViewNotice.tr,
                    );
                  }
                }),
            MeetupDoc(
                meetup: widget.meetup,
                builder: (meetup) {
                  if (meetup.users.contains(myUid)) {
                    return PostListView.gridView(
                      category: '${widget.meetup.id}${Code.meetupGalleryCategoryPostFix}',
                      padding: const EdgeInsets.fromLTRB(16, 16, 0, 16),
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
                        child: Card(
                          margin: const EdgeInsets.all(24),
                          child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Text(T.noUploadPhotoYet.tr)),
                        ),
                      ),
                    );
                  } else if (meetup.blocked == true) {
                    return MeetupViewBlocked(
                      meetup: meetup,
                      label: T.meetupViewGalleryBlocked.tr,
                    );
                  } else {
                    return MeetupViewRegisterFirstButton(
                      meetup: meetup,
                      label: T.joinMeetupToViewGallery.tr,
                    );
                  }
                }),
          ],
        ),
      ),
    );
  }
}
