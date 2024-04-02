import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/club/widgets/club.join_button.dart';
import 'package:flutter/material.dart';

class ClubDetails extends StatelessWidget {
  const ClubDetails({
    super.key,
    required this.club,
  });

  final Club club;

  @override
  Widget build(BuildContext context) {
    return ClubDoc(
      club: club,
      builder: (club) {
        return SingleChildScrollView(
          child: Column(
            children: [
              if (club.photoUrl != null)
                CachedNetworkImage(
                  imageUrl: club.photoUrl!,
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
                      child: Text(club.description),
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
                          uid: club.master,
                          builder: (user) {
                            return Row(
                              children: [
                                Text('운영자: ${user.displayName}'),
                                if (club.isMaster)
                                  IconButton(
                                    onPressed: () => ClubService.instance
                                        .showUpdateScreen(
                                            context: context, club: club),
                                    icon: const Icon(Icons.edit),
                                  ),
                              ],
                            );
                          },
                        ),
                        Text('회원 수: ${club.users.length} 명'),
                      ],
                    ),
                    const Spacer(),
                    if (club.joined == false) ClubJoinButton(club: club),
                    const SizedBox(width: 4),
                    ElevatedButton(
                      onPressed: () {
                        ChatService.instance.showChatRoomScreen(
                            context: context, uid: club.master);
                      },
                      child: const Text('문의하기'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (club.reminder.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Reminder'),
                      Card(
                        child: InkWell(
                          onTap: () => alert(
                            context: context,
                            title: 'Reminder',
                            message: club.reminder,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            width: double.infinity,
                            child: Text(
                              club.reminder.cut(128),
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
              const Text('최근 사진들'),
              PostLatestListView.gridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                category: '${club.id}-gallery',
                emptyBuilder: () => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: const Card(
                      child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('최근 사진이 없습니다.')),
                  )),
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              ),
              const SizedBox(height: 16),
              const Text('최근글'),
              Padding(
                padding: const EdgeInsets.all(16),
                child: PostLatestListView(
                  separatorBuilder: (p0, p1) => const SizedBox(height: 8),
                  category: club.id,
                  emptyBuilder: () => Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: const Card(
                        child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: Text('최근 글이 없습니다.')),
                    )),
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
