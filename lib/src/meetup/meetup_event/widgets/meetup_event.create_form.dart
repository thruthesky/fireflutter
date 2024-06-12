import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class MeetupEventCreateForm extends StatefulWidget {
  const MeetupEventCreateForm({
    super.key,
    required this.meetupId,
    required this.onCreate,
  });

  final String? meetupId;
  final void Function(MeetupEvent meetup) onCreate;

  @override
  State<MeetupEventCreateForm> createState() => _MeetupEventCreateFormState();
}

class _MeetupEventCreateFormState extends State<MeetupEventCreateForm> {
  final TextEditingController titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(T.meetupScheduleTitle.tr),
        TextField(
          controller: titleController,
          onChanged: (value) => setState(() {}),
        ),
        const SizedBox(height: 8),
        Text(T.meetupScheduleTitleDescription.tr),
        const SizedBox(height: 24),
        if (titleController.text.trim().isNotEmpty)
          Align(
            child: OutlinedButton(
              onPressed: () async {
                final meetup = await MeetupEvent.create(
                  meetupId: widget.meetupId,
                  title: titleController.text,
                );
                widget.onCreate(meetup);
              },
              child: Text(T.meetupCreateSchedule.tr),
            ),
          ),
      ],
    );
  }
}
