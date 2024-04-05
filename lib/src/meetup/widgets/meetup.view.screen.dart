import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/meetup/meetup.service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MeetupViewScreen extends StatefulWidget {
  const MeetupViewScreen({
    super.key,
    required this.meetup,
  });

  final Meetup meetup;

  @override
  State<MeetupViewScreen> createState() => _MeetupViewScreenState();
}

class _MeetupViewScreenState extends State<MeetupViewScreen> {
  /// 클럽에 연결된 밋업이면 클럽 정보를 가져온다.
  Club? club;

  @override
  void initState() {
    super.initState();
    if (widget.meetup.clubId != null) {
      Club.get(id: widget.meetup.clubId!).then((value) => club = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MeetupDoc(
      meetup: widget.meetup,
      builder: (meetup) => Scaffold(
        appBar: AppBar(
          title: Text(widget.meetup.title),
          actions: [
            IconButton(
              onPressed: () {
                MeetupService.instance.showUpdateScreen(
                  context: context,
                  meetup: widget.meetup,
                );
              },
              icon: const Icon(
                Icons.edit,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (meetup.photoUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: meetup.photoUrl!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                "모임 날짜 & 시간",
                style: Theme.of(context).textTheme.labelSmall,
              ),
              if (meetup.meetAt != null)
                Row(
                  children: [
                    Text(DateFormat.yMMMEd('ko').format(meetup.meetAt!)),
                    const SizedBox(width: 10),
                    Text(
                      DateFormat.jm('ko').format(meetup.meetAt!),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              Text(
                '모임 설명',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              SizedBox(
                width: double.infinity,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(meetup.description),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (meetup.joined)
                ElevatedButton(
                  onPressed: () async {
                    if (club != null && club!.joined == false) {
                      error(
                          context: context,
                          title: '클럽 가입 필요',
                          message: '모임에 먼저 가입을 해 주세요.');
                      return;
                    }
                    await meetup.leave();
                    toast(context: context, message: '참석을 취소했습니다.');
                  },
                  child: const Text('참석 취소하기'),
                )
              else
                ElevatedButton(
                  onPressed: () async {
                    if (club != null && club!.joined == false) {
                      error(
                          context: context,
                          title: '클럽 가입 필요',
                          message: '모임에 먼저 가입을 하신 다음, 참석 신청을 주세요.');
                      return;
                    }
                    await meetup.join();
                    toast(context: context, message: '참석 신청했습니다.');
                  },
                  child: const Text('참석 신청하기'),
                ),
              const SizedBox(height: 16),
              const Text('참석 신청자 목록'),
              if (meetup.users.isNotEmpty)
                Wrap(
                  children: meetup.users
                      .map(
                        (uid) => Padding(
                          padding: const EdgeInsets.all(8),
                          child: UserAvatar.sync(
                            uid: uid,
                            size: 64,
                            radius: 26,
                          ),
                        ),
                      )
                      .toList(),
                )
              else
                const Text('참석 신청자가 없습니다.'),
            ],
          ),
        ),
      ),
    );
  }
}
