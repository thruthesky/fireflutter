import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class MeetupJoinButton extends StatelessWidget {
  const MeetupJoinButton({
    super.key,
    required this.meetup,
  });

  final Meetup meetup;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (notLoggedIn) {
          await alert(
            context: context,
            title: T.login.tr,
            message: T.loginFirstToUseMeetup.tr,
          );
          return;
        } else {
          if (meetup.joined) {
            await meetup.leave();
          } else {
            await meetup.join();
          }
        }
      },
      child: Text(
        meetup.joined ? T.unsubscribed.tr : T.signup.tr,
      ),
    );
  }
}
