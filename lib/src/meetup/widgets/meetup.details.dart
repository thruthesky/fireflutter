import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/meetup/widgets/meetup.join_button.dart';
import 'package:flutter/material.dart';

class MeetupDetails extends StatelessWidget {
  const MeetupDetails({
    super.key,
    required this.meetup,
  });

  final Meetup meetup;

  @override
  Widget build(BuildContext context) {
    return MeetupDoc(
      meetup: meetup,
      builder: (meetup) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (meetup.photoUrl != null)
                CachedNetworkImage(
                  imageUrl: meetup.photoUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(meetup.description),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        UserDoc(
                          uid: meetup.master,
                          builder: (user) {
                            return Row(
                              children: [
                                Text('${T.host.tr}: ${user.displayName}'),
                                if (meetup.isMaster)
                                  IconButton(
                                    onPressed: () => MeetupService.instance
                                        .showUpdateScreen(
                                            context: context, meetup: meetup),
                                    icon: const Icon(Icons.edit),
                                  ),
                              ],
                            );
                          },
                        ),
                        Text(
                            '${T.members.tr}: ${meetup.users.length} ${T.noOfPeople.tr}'),
                      ],
                    ),
                    const Spacer(),
                    if (meetup.joined == false)
                      MeetupJoinButton(meetup: meetup),
                    const SizedBox(width: 4),
                    ElevatedButton(
                      onPressed: () {
                        ChatService.instance.showChatRoomScreen(
                          context: context,
                          otherUid: meetup.master,
                        );
                      },
                      child: Text(T.contact.tr),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (meetup.reminder.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(T.reminder.tr),
                      Card(
                        child: InkWell(
                          onTap: () => alert(
                            context: context,
                            title: T.reminder.tr,
                            message: meetup.reminder,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            width: double.infinity,
                            child: Text(
                              meetup.reminder.cut(128),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(T.recentPhotos.tr),
              ),
              PostLatestListView.gridView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                category: '${meetup.id}-meetup-gallery',
                emptyBuilder: () => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: Card(
                      child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(child: Text(T.noRecentPhotos.tr)),
                  )),
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(T.recentPhotos.tr),
              ),
              PostLatestListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                separatorBuilder: (p0, p1) => const SizedBox(height: 8),
                category: '${meetup.id}-meetup-post',
                emptyBuilder: () => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: Card(
                      child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text(T.noRecentPosts.tr),
                    ),
                  )),
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              ),
              const SizedBox(height: 64),
            ],
          ),
        );
      },
    );
  }
}
