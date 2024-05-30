import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class MeetupAdminSettingsScreen extends StatefulWidget {
  const MeetupAdminSettingsScreen({
    super.key,
    required this.meetup,
  });

  final Meetup meetup;

  @override
  State<MeetupAdminSettingsScreen> createState() => _MeetupAdminSettingsState();
}

class _MeetupAdminSettingsState extends State<MeetupAdminSettingsScreen> {
  Meetup? meetup;

  @override
  void initState() {
    super.initState();

    meetup = widget.meetup;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(T.meetupAdminSettings.tr),
      ),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Text('list settings here'),
      ),
    );
  }
}
