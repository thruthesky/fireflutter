import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:new_app/home/chat.room/chat.room.dart';
import 'package:new_app/home/forums/land.page.dart';
import 'package:new_app/home/user_profile/main.page.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key, required this.selectedIndex});
  final int selectedIndex;

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  void initState() {
    super.initState();
  }

  final double iconSize = sizeSm;
  double top = 0;
  double left = 135;
  double right = 240;

  @override
  Widget build(BuildContext context) {
    switch (widget.selectedIndex) {
      case 0:
        setState(() {
          left = 24;
          right = 350;
        });
        break;
      case 2:
        setState(() {
          left = 240;
          right = 135;
        });
        break;
      case 3:
        setState(() {
          right = 24;
          left = 350;
        });
        break;
      case 1:
      default:
        break;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        height: 60,
        child: Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _iconButtonBuilder(FontAwesomeIcons.peopleGroup, 0,
                    onPressed: () => context.push(PostHome.routeName)), // 0
                _iconButtonBuilder(FontAwesomeIcons.solidMessage, 1,
                    onPressed: () => context.push(ChatRoom.routeName)), // 1
                _iconButtonBuilder(FontAwesomeIcons.solidUser, 2,
                    onPressed: () => context.push(MainPage.routeName)), // 2
                _iconButtonBuilder(FontAwesomeIcons.shield, 3, onPressed: () => context.push('/TestUi')), // 3
              ],
            ),
            AnimatedPositioned(
              duration: const Duration(seconds: 1),
              top: top,
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

  Widget _iconButtonBuilder(IconData icon, int index, {VoidCallback? onPressed}) {
    return IconButton(
      onPressed: () {
        onPressed?.call();
        setState(() {});
      },
      icon: FaIcon(
        icon,
        size: sizeSm,
        color: index == widget.selectedIndex
            ? Theme.of(context).shadowColor
            : Theme.of(context).shadowColor.withAlpha(100),
      ),
    );
  }
}

// AnimatedPositioned(
//           duration: const Duration(seconds: 3),
//           top: 0,
//           right: 5,
//           left: 5,
//           child: Visibility(
//             visible: index == widget.selectedIndex,
//             maintainAnimation: true,
//             maintainState: true,
//             child: Container(
//               height: 3,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(40),
//                 color: Theme.of(context).shadowColor,
//               ),
//             ),
//           ),
//         ),
class FloatingButton extends StatelessWidget {
  const FloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {},
      child: const FaIcon(FontAwesomeIcons.user),
    );
  }
}

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    // built as Widget [??] PrefferedSizeWidget need
    return AppBar(
      title: Text(
        'Profile',
        style: TextStyle(
          color: Theme.of(context).primaryColor,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(
            right: 16,
            top: 10,
            bottom: 10,
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).hintColor.withAlpha(80),
              minimumSize: const Size.fromWidth(8),
              elevation: 0,
            ),
            onPressed: () {
              UserService.instance.signOut();
            },
            child: const Text(
              'Logout',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
      forceMaterialTransparency: true,
      elevation: 0,
    );
  }
}
