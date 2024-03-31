import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ClubMeetupCreateForm extends StatefulWidget {
  const ClubMeetupCreateForm({
    super.key,
    required this.club,
    required this.onCreate,
  });

  final Club club;
  final void Function(ClubMeetup club) onCreate;

  @override
  State<ClubMeetupCreateForm> createState() => _ClubMeetupCreateFormState();
}

/// TODO: 여기서 부터...
class _ClubMeetupCreateFormState extends State<ClubMeetupCreateForm> {
  final TextEditingController titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("오프라인 모임 제목"),
        TextField(
          controller: titleController,
          onChanged: (value) => setState(() {}),
        ),
        const SizedBox(height: 8),
        const Text("오프라인 모임 제목을 적어주세요."),
        const SizedBox(height: 24),
        if (titleController.text.trim().isNotEmpty)
          Align(
            child: OutlinedButton(
              onPressed: () async {
                final meetup = await ClubMeetup.create(
                  clubId: widget.club.id,
                  title: titleController.text,
                );
                widget.onCreate(meetup);
              },
              child: const Text('모임 만들기'),
            ),
          ),
      ],
    );
  }
}
