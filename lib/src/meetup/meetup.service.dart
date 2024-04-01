import 'package:fireflutter/src/meetup/meetup_edit.screen.dart';
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
}
