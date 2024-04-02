import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/meetup/widgets/meetup.view.screen.dart';
import 'package:flutter/material.dart';

class MeetupService {
  static MeetupService? _instance;
  static MeetupService get instance => _instance ??= MeetupService._();

  MeetupService._();

  showCreateScreen({
    required BuildContext context,
    required String? clubId,
  }) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) => MeetupEditScreen(
        clubId: clubId,
      ),
    );
  }

  showUpdateScreen({
    required BuildContext context,
    required Meetup meetup,
  }) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) => MeetupEditScreen(
        meetup: meetup,
      ),
    );
  }

  showViewScreen({
    required BuildContext context,
    required Meetup meetup,
  }) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) => MeetupViewScreen(
        meetup: meetup,
      ),
    );
  }
}
