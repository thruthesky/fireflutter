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
        if (notLoggedIn) {
          await alert(
            context: context,
            title: '로그인',
            message: '모임 기능을 이용하기 위해서는 로그인을 먼저 하셔야합니다.',
          );
          return;
        } else {
          if (club.joined) {
            await club.leave();
          } else {
            await club.join();
          }
        }
      },
      child: Text(
        club.joined ? '탈퇴하기' : '가입하기',
      ),
    );
  }
}
