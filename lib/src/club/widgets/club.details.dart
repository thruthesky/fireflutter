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
              Text(club.description),
              if (club.joined == false) ClubJoinButton(club: club),
              ElevatedButton(
                  onPressed: () {
                    ChatService.instance
                        .showChatRoomScreen(context: context, uid: club.master);
                  },
                  child: const Text('문의하기')),
              Text('회원 수: ${club.users.length} 명'),
              UserDoc(
                  uid: club.master,
                  builder: (user) {
                    return Row(
                      children: [
                        Text('운영자: ${user.displayName}'),
                        if (club.isMaster)
                          ElevatedButton(
                            onPressed: () => ClubService.instance
                                .showUpdateScreen(context: context, club: club),
                            child: const Text('모임 설정'),
                          ),
                      ],
                    );
                  }),
              const Text('@TODO 일정 - 우선 가장 간단하게 만들 것.'),
              if (club.reminder.isNotEmpty) ...[
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
              const Divider(),
              const Text('최근 사진들'),
              PostLatestListView.gridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                category: '${club.id}-gallery',
                emptyBuilder: () => const Card(child: Text('최근 사진이 없습니다.')),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              ),
              const Text('최근글'),
              PostLatestListView(
                category: club.id,
                emptyBuilder: () => const Card(child: Text('최근 글이 없습니다.')),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              ),
            ],
          ),
        );
      },
    );
  }
}
