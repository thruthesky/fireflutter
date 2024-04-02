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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("모임 날짜 & 시간"),
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
            const Text('모임 설명'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(meetup.description),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('참석 신청'),
            ),
            const Text('참석 신청자 목록'),
          ],
        ),
      ),
    );
  }
}
