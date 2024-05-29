import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class MeetupEventService {
  static MeetupEventService? _instance;
  static MeetupEventService get instance =>
      _instance ??= MeetupEventService._();

  MeetupEventService._();

  showCreateScreen({
    required BuildContext context,
    required String? meetupId,
  }) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) =>
          MeetupEventEditScreen(
        meetupId: meetupId,
      ),
    );
  }

  showUpdateScreen({
    required BuildContext context,
    required MeetupEvent event,
  }) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) =>
          MeetupEventEditScreen(
        event: event,
      ),
    );
  }

  showViewScreen({
    required BuildContext context,
    required MeetupEvent event,
  }) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) =>
          MeetupEventViewScreen(
        event: event,
      ),
    );
  }
}
