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
      child: Card(
        margin: const EdgeInsets.all(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FittedBox(child: MeetupJoinButton(meetup: meetup)),
            ],
          ),
        ),
      ),
    );
  }
}
