// import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:new_app/home.screen/user.profile.dart';
import 'package:new_app/page.essentials/app.bar.dart';
import 'package:new_app/page.essentials/bottom.navbar.dart';
import 'package:new_app/router/router.dart';

class MainPage extends StatefulWidget {
  static const String routeName = '/MainPage';
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
    );
  }
}

class MainPageBody extends StatefulWidget {
  const MainPageBody({super.key});

  @override
  State<MainPageBody> createState() => _MainPageBodyState();
}

class _MainPageBodyState extends State<MainPageBody> {
  @override
  void initState() {
    super.initState();
    // Add menu(s) on top of public screen
    // UserService.instance.customize.publicScreenActions = (context, user) => [
    //       FavoriteButton(
    //         otherUid: user.uid,
    //         builder: (re) => FaIcon(
    //           re ? FontAwesomeIcons.star : FontAwesomeIcons.starHalf,
    //           color: re ? Colors.yellow : null,
    //         ),
    //         onChanged: (re) => toast(
    //           title: re ? tr.favorite : tr.unfavorite,
    //           message: re ? tr.favoriteMessage : tr.unfavoriteMessage,
    //         ),
    //       ),
    //       PopupMenuButton(
    //         itemBuilder: (context) => [
    //           PopupMenuItem(
    //             value: 'report',
    //             child: Text(tr.report),
    //           ),
    //           PopupMenuItem(
    //             value: 'block',
    //             child: Database(
    //               path: pathBlock(user.uid),
    //               builder: (value, text) => Text(value == null ? tr.block : tr.unblock),
    //             ),
    //           ),
    //         ],
    //         icon: const FaIcon(FontAwesomeIcons.ellipsis),
    //         onSelected: (value) {
    //           switch (value) {
    //             case 'report':
    //               ReportService.instance.showReportDialog(
    //                 context: context,
    //                 otherUid: user.uid,
    //                 onExists: (id, type) => toast(
    //                   title: tr.alreadyReportedTitle,
    //                   message: tr.alreadyReportedMessage.replaceAll('#type', type),
    //                 ),
    //               );
    //               break;
    //             case 'block':
    //               toggle(pathBlock(user.uid));
    //               toast(
    //                 title: tr.block,
    //                 message: tr.blockMessage,
    //               );
    //               break;
    //           }
    //         },
    //       ),
    //     ];

    // /// Hide some buttons on bottom.
    // UserService.instance.customize.publicScreenBlockButton = (context, user) => const SizedBox.shrink();
    // UserService.instance.customize.publicScreenReportButton = (context, user) => const SizedBox.shrink();

    UserService.instance.init(enableNoOfProfileView: true, adminUid: myUid!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Profile'),
      body: const UserProfile(),
      bottomNavigationBar: const BottomNavBar(index: 2),
    );
  }
}
