import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class MeetupDoc extends StatelessWidget {
  const MeetupDoc({
    super.key,
    required this.meetup,
    required this.builder,
  });

  final Meetup meetup;
  final Widget Function(Meetup) builder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Meetup>(
      initialData: meetup,
      stream: meetup.ref.snapshots().map(
            (event) => Meetup.fromSnapshot(event),
          ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final meetup = snapshot.data!;
        return builder(meetup);
      },
    );
  }
}
