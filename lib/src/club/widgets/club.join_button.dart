import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ClubJoinButton extends StatelessWidget {
  const ClubJoinButton({
    super.key,
    required this.club,
  });

  final Club club;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (club.joined) {
          await club.leave();
        } else {
          await club.join();
        }
      },
      child: Text(
        club.joined ? '탈퇴하기' : '가입하기',
      ),
    );
  }
}
