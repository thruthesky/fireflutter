import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ClubDetails extends StatelessWidget {
  const ClubDetails({
    super.key,
    required this.club,
  });

  final Club club;

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text("모임 소개. @TODO  보고 따라 만든다."),
        Text('가입하기'),
        Text('공유하기'),
        Text('문의하기'),
        Text('회원 수'),
        Text('운영자'),
        Text('일정'),
        Text('공지사항'),
        Text('사진'),
        Text('최근글'),
      ],
    );
  }
}
