import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ClubMeetupEditScreen extends StatefulWidget {
  const ClubMeetupEditScreen({super.key, this.club});

  final Club? club;

  @override
  State<ClubMeetupEditScreen> createState() => _ClubMeetupEditScreenState();
}

class _ClubMeetupEditScreenState extends State<ClubMeetupEditScreen> {
  Club? club;

  @override
  void initState() {
    super.initState();

    if (widget.club != null) {
      club = widget.club;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(club == null ? '모임 일정 만들기' : '모임 일정 수정하기'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: club == null
            ? ClubCreateForm(
                onCreate: (club) => setState(() => this.club = club),
              )
            : ClubUpdateForm(
                club: club!,
              ),
      ),
    );
  }
}
