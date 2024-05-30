import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class MeetupEditScreen extends StatefulWidget {
  const MeetupEditScreen({super.key, this.meetup});

  final Meetup? meetup;

  @override
  State<MeetupEditScreen> createState() => _ClubEditScreenState();
}

class _ClubEditScreenState extends State<MeetupEditScreen> {
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
        title: Text(
          meetup == null ? T.meetupCreate.tr : T.meetupUpdate.tr,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: meetup == null
            ? MeetupCreateForm(
                onCreate: (meetup) => setState(() => this.meetup = meetup),
              )
            : MeetupUpdateForm(
                meetup: meetup!,
              ),
      ),
    );
  }
}
