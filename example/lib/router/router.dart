import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:new_app/chat.room/chat.room.dart';
import 'package:new_app/forums/feed.dart';
import 'package:new_app/forums/land.page.dart';
import 'package:new_app/home.screen/main.page.dart';
import 'package:new_app/main.dart';
import 'package:new_app/page.essentials/app.bar.dart';
import 'package:new_app/page.essentials/bottom.navbar.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: LoginPage.routeName,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: LoginPageBody(),
      ),
    ),
    GoRoute(
      path: MainPage.routeName,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: MainPageBody(),
      ),
    ),
    GoRoute(
      path: ChatRoom.routeName,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: CustomChatRoom(),
      ),
    ),
    GoRoute(
      path: PostHome.routeName,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: NewsFeed(),
      ),
    ),
    GoRoute(
      path: '/TestUi',
      pageBuilder: (context, state) => NoTransitionPage(
        child: MaterialApp(
          home: Scaffold(
            appBar: appBar('TestUi', hasLeading: true),
            body: const TestUi(),
            bottomNavigationBar: const BottomNavBar(index: 3),
          ),
        ),
      ),
    )
  ],
);
