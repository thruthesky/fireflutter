import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/meetup/widgets/meetup.join_button.dart';
import 'package:flutter/material.dart';

class MeetupViewRegisterFirstButton extends StatelessWidget {
  const MeetupViewRegisterFirstButton({
    super.key,
    required this.meetup,
    required this.label,
  });

  final Meetup meetup;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
          ),
          MeetupJoinButton(meetup: meetup),
        ],
      ),
    );
  }
}
