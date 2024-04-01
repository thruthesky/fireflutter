import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/club/widgets/club.join_button.dart';
import 'package:flutter/material.dart';

class ClubViewRegisterFirst extends StatelessWidget {
  const ClubViewRegisterFirst({
    super.key,
    required this.club,
    required this.label,
  });

  final Club club;
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
          ClubJoinButton(club: club),
        ],
      ),
    );
  }
}
