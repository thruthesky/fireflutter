import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class MeetupViewBlocked extends StatelessWidget {
  const MeetupViewBlocked({
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
              const Icon(
                Icons.block,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                label,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
