import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ProfileViewers extends StatelessWidget {
  const ProfileViewers({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size.height / 6,
      child: Theme(
        data: ThemeData(
          appBarTheme: const AppBarTheme(
            toolbarHeight: 0,
          ),
          primaryTextTheme: const TextTheme(),
          iconButtonTheme: IconButtonThemeData(
            style: ButtonStyle(
              iconColor: MaterialStateColor.resolveWith((states) => Theme.of(context).shadowColor),
            ),
          ),
        ),
        child: const ProfileViewersListScreen(),
      ),
    );
  }
}
