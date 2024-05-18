import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// MeetupEventDoc
///
/// A widget that listens to a event event and rebuilds the UI when the event
class MeetupEventDoc extends StatelessWidget {
  const MeetupEventDoc({
    super.key,
    required this.event,
    required this.builder,
  });

  final MeetupEvent event;
  final Widget Function(MeetupEvent) builder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MeetupEvent>(
      initialData: event,
      stream: event.ref.snapshots().map(
            (event) => MeetupEvent.fromSnapshot(event),
          ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final event = snapshot.data!;
        return builder(event);
      },
    );
  }
}
