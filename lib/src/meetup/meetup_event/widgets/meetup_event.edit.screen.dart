import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class MeetupEventEditScreen extends StatefulWidget {
  const MeetupEventEditScreen({super.key, this.meetupId, this.event});

  final String? meetupId;
  final MeetupEvent? event;

  @override
  State<MeetupEventEditScreen> createState() => _ClubMeetupEditScreenState();
}

class _ClubMeetupEditScreenState extends State<MeetupEventEditScreen> {
  MeetupEvent? event;

  @override
  void initState() {
    super.initState();

    if (widget.event != null) {
      event = widget.event;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          event == null ? T.createMeetupSchedule.tr : T.editMeetupSchedule.tr,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: event == null
            ? MeetupEventCreateForm(
                meetupId: widget.meetupId!,
                onCreate: (event) => setState(() => this.event = event),
              )
            : MeetupEventUpdateForm(
                event: event!,
              ),
      ),
    );
  }
}
