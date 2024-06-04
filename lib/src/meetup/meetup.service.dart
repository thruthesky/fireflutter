import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MeetupService {
  static MeetupService? _instance;
  static MeetupService get instance => _instance ?? MeetupService._();

  Query get recommendedQuery => Meetup.col
      .where('hasPhoto', isEqualTo: true)
      .orderBy('recommendOrder', descending: true);

  MeetupService._();

  showViewScreen({
    required BuildContext context,
    required Meetup meetup,
  }) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) =>
          MeetupViewScreen(meetup: meetup),
    );
  }

  showCreateScreen({
    required BuildContext context,
  }) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) =>
          const MeetupEditScreen(),
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
}
