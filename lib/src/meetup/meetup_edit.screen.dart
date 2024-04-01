import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class MeetupEditScreen extends StatefulWidget {
  const MeetupEditScreen({super.key, this.clubId, this.meetup});

  final String? clubId;
  final Meetup? meetup;

  @override
  State<MeetupEditScreen> createState() => _ClubMeetupEditScreenState();
}

class _ClubMeetupEditScreenState extends State<MeetupEditScreen> {
  Meetup? meetup;

  @override
  void initState() {
    super.initState();

    if (widget.meetup != null) {
      meetup = widget.meetup;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(meetup == null ? '만남 일정 만들기' : '만남 일정 수정하기'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: meetup == null
            ? MeetupCreateForm(
                clubId: widget.clubId!,
                onCreate: (meetup) => setState(() => this.meetup = meetup),
              )
            : MeetupUpdateForm(
                meetup: meetup!,
              ),
      ),
    );
  }
}
