import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:new_app/chat.room/chat.room.dart';
import 'package:new_app/forums/land.page.dart';
import 'package:new_app/home.screen/main.page.dart';
import 'package:new_app/inits.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key, required this.index});
  final int index;

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  void initState() {
    super.initState();
    userInit();
  }

  final double iconSize = sizeSm;
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.index,
      onTap: (value) => setState(() {}),
      items: [
        BottomNavigationBarItem(
          icon: IconButton(
            onPressed: () {
              context.go(PostHome.routeName);
            },
            icon: const FaIcon(
              FontAwesomeIcons.peopleGroup,
              // size: iconSize,
            ),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: IconButton(
            onPressed: () {
              context.go(ChatRoom.routeName);
              // ChatService.instance.showChatRoom(context: context, user: my);
            },
            icon: const FaIcon(
              FontAwesomeIcons.solidMessage,
              // size: iconSize,
            ),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: IconButton(
            onPressed: () {
              context.go(MainPage.routeName);
            },
            icon: const FaIcon(
              FontAwesomeIcons.solidUser,
              // size: iconSize,
            ),
          ),
          label: '',
        ),
      ],
      elevation: 5,
      iconSize: sizeMd - 4,
    );
  }
}

// Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//       ],
//     );

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
