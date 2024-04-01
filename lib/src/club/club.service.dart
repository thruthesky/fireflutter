import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ClubService {
  static ClubService? _instance;
  static ClubService get instance => _instance ?? ClubService._();

  ClubService._();

  showViewScreen({
    required BuildContext context,
    required Club club,
  }) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) =>
          ClubViewScreen(club: club),
    );
  }

  showCreateScreen({
    required BuildContext context,
  }) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) =>
          const ClubEditScreen(),
    );
  }

  showUpdateScreen({
    required BuildContext context,
    required Club club,
  }) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) => ClubEditScreen(
        club: club,
      ),
    );
  }
}
