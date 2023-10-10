import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:new_app/main.dart';

class TitleText extends StatelessWidget {
  const TitleText({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Theme.of(context).shadowColor,
        fontSize: sizeMd - 4,
        fontWeight: FontWeight.bold,
        // letterSpacing: -1,
      ),
    );
  }
}

class AppBarAction extends StatelessWidget {
  const AppBarAction({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        right: 16,
        top: 13,
        bottom: 16,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).hintColor.withAlpha(80),
          minimumSize: const Size.fromWidth(8),
          elevation: 0,
        ),
        onPressed: () {
          UserService.instance.signOut();
          context.go(LoginPage.routeName);
          // context.pop();
        },
        child: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class LeadingButton extends StatelessWidget {
  const LeadingButton({super.key});
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: FaIcon(
        FontAwesomeIcons.chevronLeft,
        color: Theme.of(context).shadowColor,
      ),
      onPressed: () => context.pop(),
    );
  }
}

AppBar appBar(String text, {bool hasLeading = false, bool hasActions = true}) {
  return AppBar(
    leading: hasLeading ? const LeadingButton() : const SizedBox.shrink(),
    title: TitleText(text: text),
    actions: [
      hasActions ? const AppBarAction() : const SizedBox.shrink(),
    ],
    forceMaterialTransparency: true,
    centerTitle: true,
  );
}

AppBar customAppBar(BuildContext context, Room? room) {
  return AppBar(
    forceMaterialTransparency: true,
    leading: const LeadingButton(),
    title: room!.isGroupChat
        ? Text(
            room.name,
            style: TextStyle(
              color: Theme.of(context).shadowColor,
            ),
          )
        : UserDoc(
            builder: (user) => Text(
              user.name,
              style: TextStyle(
                color: Theme.of(context).shadowColor,
              ),
            ),
            uid: otherUserUid(room.users),
            live: false,
          ),
    actions: [
      IconButton(
        icon: Icon(
          Icons.settings,
          color: Theme.of(context).shadowColor,
        ),
        onPressed: () async {
          return showDialog(
            context: context,
            builder: ((context) {
              return Theme(
                data: ThemeData(
                  appBarTheme: AppBarTheme(
                      backgroundColor: Theme.of(context).canvasColor,
                      iconTheme: IconThemeData(
                        color: Theme.of(context).shadowColor,
                      ),
                      elevation: 0),
                ),
                child: ChatRoomMenuScreen(room: room),
              );
            }),
          );
          // return ChatService.instance.openChatRoomMenuDialog(context: context, room: room);
        },
      ),
    ],
  );
}
