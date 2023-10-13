import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:new_app/home/chat.room/chat.room.dart';
import 'package:new_app/home/forum/feed.body.dart';
import 'package:new_app/home/user.profile/user.profile.dart';
import 'package:new_app/page.essentials/app.bar.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({
    super.key,
  });

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  Widget child = const UserProfile();
  int index = 2;
  String appBarName = 'Profile';
  final double iconSize = sizeSm;
  double left = 240;
  double right = 135;

  void state(Widget? child, String appBarName, int index,
      {double left = 240, double right = 135}) {
    setState(() {
      this.child = child ?? const SizedBox.shrink();
      this.appBarName = appBarName;
      // for animation
      this.left = left;
      this.right = right;
      this.index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(appBarName),
      body: child,
      bottomNavigationBar: bottomNavBar(context),
    );
  }

  Widget bottomNavBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        height: 60,
        child: Stack(
          children: [
            _icons(context),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              top: 0,
              right: right,
              left: left,
              child: Container(
                height: 3,
                width: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  color: Theme.of(context).shadowColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Row _icons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _iconButtonBuilder(FontAwesomeIcons.peopleGroup, 0), // 0
        _iconButtonBuilder(FontAwesomeIcons.solidMessage, 1), // 1
        _iconButtonBuilder(FontAwesomeIcons.solidUser, 2), // 2
        _iconButtonBuilder(FontAwesomeIcons.shield, 3,
            onPressed: () => context.push('/TestUi')), // 3
        // _iconButtonBuilder(FontAwesomeIcons.stackOverflow, 4), // 4
      ],
    );
  }

  Widget _iconButtonBuilder(IconData icon, int index,
      {VoidCallback? onPressed}) {
    return IconButton(
      onPressed: () {
        switch (index) {
          case 0:
            state(const FeedBody(), 'Forum', index, left: 24, right: 350);
            break;
          case 1:
            state(const ChatRoom(), 'Chats', index, left: 135, right: 240);
            break;
          case 2:
            state(const UserProfile(), 'Profile', index, left: 240, right: 135);
            break;
          case 3:
            state(const TestUi(), 'Admin', index, left: 350, right: 24);
            break;
          // case 4:
          //   state(const MyDocSample(), 'Forum', index, left: 24, right: 350);
          // break;
          default:
            child = const SizedBox.shrink();
            break;
        }
      },
      icon: FaIcon(
        icon,
        size: sizeSm,
        color: this.index == index
            ? Theme.of(context).shadowColor
            : Theme.of(context).shadowColor.withAlpha(100),
      ),
    );
  }
}

class MyDocSample {
  const MyDocSample();
}
