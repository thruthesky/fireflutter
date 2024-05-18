import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class MeetupCreateForm extends StatefulWidget {
  const MeetupCreateForm({
    super.key,
    required this.onCreate,
  });

  final void Function(Meetup meetup) onCreate;

  @override
  State<MeetupCreateForm> createState() => _ClubCreateFormState();
}

class _ClubCreateFormState extends State<MeetupCreateForm> {
  final TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(T.clubName.tr),
        TextField(
          controller: nameController,
          onChanged: (value) => setState(() {}),
        ),
        const SizedBox(height: 8),
        Text(T.clubNameDescription.tr),
        const SizedBox(height: 24),
        if (nameController.text.trim().isNotEmpty)
          Align(
            child: OutlinedButton(
              onPressed: () async {
                final club = await Meetup.create(name: nameController.text);
                widget.onCreate(club);
              },
              child: Text(T.clubCreate.tr),
            ),
          ),
      ],
    );
  }
}
