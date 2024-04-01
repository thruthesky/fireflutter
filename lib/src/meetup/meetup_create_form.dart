import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class MeetupCreateForm extends StatefulWidget {
  const MeetupCreateForm({
    super.key,
    required this.clubId,
    required this.onCreate,
  });

  final String? clubId;
  final void Function(Meetup meetup) onCreate;

  @override
  State<MeetupCreateForm> createState() => _ClubMeetupCreateFormState();
}

class _ClubMeetupCreateFormState extends State<MeetupCreateForm> {
  final TextEditingController titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("오프라인 일정 제목"),
        TextField(
          controller: titleController,
          onChanged: (value) => setState(() {}),
        ),
        const SizedBox(height: 8),
        const Text("오프라인 만남의 제목을 적어주세요."),
        const SizedBox(height: 24),
        if (titleController.text.trim().isNotEmpty)
          Align(
            child: OutlinedButton(
              onPressed: () async {
                final meetup = await Meetup.create(
                  clubId: widget.clubId,
                  title: titleController.text,
                );
                widget.onCreate(meetup);
              },
              child: const Text('일정 만들기'),
            ),
          ),
      ],
    );
  }
}
