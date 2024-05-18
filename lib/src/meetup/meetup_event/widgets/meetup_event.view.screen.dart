import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MeetupEventViewScreen extends StatefulWidget {
  const MeetupEventViewScreen({
    super.key,
    required this.event,
  });

  final MeetupEvent event;

  @override
  State<MeetupEventViewScreen> createState() => _MeetupViewScreenState();
}

class _MeetupViewScreenState extends State<MeetupEventViewScreen> {
  /// 클럽에 연결된 밋업이면 클럽 정보를 가져온다.
  Meetup? event;

  @override
  void initState() {
    super.initState();
    if (widget.event.clubId != null) {
      Meetup.get(id: widget.event.clubId!).then((value) => event = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MeetupEventDoc(
      event: widget.event,
      builder: (event) => Scaffold(
        appBar: AppBar(
          title: Text(widget.event.title),
          actions: [
            IconButton(
              onPressed: () {
                MeetupEventService.instance.showUpdateScreen(
                  context: context,
                  event: widget.event,
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
              if (event.photoUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: event.photoUrl!,
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
              if (event.meetAt != null)
                Row(
                  children: [
                    Text(DateFormat.yMMMEd('ko').format(event.meetAt!)),
                    const SizedBox(width: 10),
                    Text(
                      DateFormat.jm('ko').format(event.meetAt!),
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
                    child: Text(event.description),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (event.joined)
                ElevatedButton(
                  onPressed: () async {
                    if (event.joined == false) {
                      error(
                          context: context,
                          title: '클럽 가입 필요',
                          message: '모임에 먼저 가입을 해 주세요.');
                      return;
                    }
                    await event.leave();
                    toast(context: context, message: '참석을 취소했습니다.');
                  },
                  child: const Text('참석 취소하기'),
                )
              else
                ElevatedButton(
                  onPressed: () async {
                    if (event.joined == false) {
                      error(
                          context: context,
                          title: '클럽 가입 필요',
                          message: '모임에 먼저 가입을 하신 다음, 참석 신청을 주세요.');
                      return;
                    }
                    await event.join();
                    toast(context: context, message: '참석 신청했습니다.');
                  },
                  child: const Text('참석 신청하기'),
                ),
              const SizedBox(height: 16),
              const Text('참석 신청자 목록'),
              if (event.users.isNotEmpty)
                Wrap(
                  children: event.users
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
