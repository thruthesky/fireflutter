import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:new_app/main.dart';
import 'package:new_app/page.essentials/button_row.dart';

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
          context.go(MainApp.routeName);
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

// custom app bar of an app
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

// custom app bar for chat room
AppBar customAppBar(BuildContext context, Room? room) {
  final renameValue = TextEditingController();
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
            builder: (other) => Text(
              other.name,
              style: TextStyle(
                color: Theme.of(context).shadowColor,
              ),
            ),
            uid: otherUserUid(room.users),
          ),
    actions: [
      IconButton(
        icon: const FaIcon(FontAwesomeIcons.penToSquare),
        color: Theme.of(context).shadowColor,
        onPressed: () => showDialog(
          context: context,
          builder: (_) => Dialog(
            insetAnimationDuration: const Duration(milliseconds: 250),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * .20,
              child: Padding(
                padding: const EdgeInsets.all(sizeSm),
                child: Column(
                  children: [
                    const Text(
                      'Rename Chat Room',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: sizeSm,
                      ),
                    ),
                    const SizedBox(height: sizeSm),
                    TextField(
                      controller: renameValue,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(sizeXs),
                          borderSide: const BorderSide(
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    ButtonRow(
                      label1: 'Update',
                      action1: () async {
                        debugPrint(myUid!);
                        await ChatService.instance.updateMyRoomSetting(
                          room: room,
                          setting: 'rename',
                          value: renameValue.text,
                        );
                      },
                      label2: 'Cancel',
                      action2: () => context.pop(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
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
        },
      ),
    ],
  );
}
