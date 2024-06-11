import 'package:example/screens/buyandsell/buyandsell.screen.dart';
import 'package:example/screens/chat/chat.screen.dart';
import 'package:example/screens/chat/custom_chat.screen.dart';
import 'package:example/screens/chat/open_chat.screen.dart';
import 'package:example/screens/entry/entry.screen.dart';
import 'package:example/screens/forum/forum.screen.dart';
import 'package:example/screens/home/home.screen.dart';
import 'package:example/screens/meetup/meetup.screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey();
BuildContext get globalContext => globalNavigatorKey.currentContext!;

/// GoRouter
final router = GoRouter(
  navigatorKey: globalNavigatorKey,
  redirect: (context, state) {
    if (state.fullPath == EntryScreen.routeName) {
      return null;
    } else {
      if (FirebaseAuth.instance.currentUser == null) {
        return EntryScreen.routeName;
      } else {
        return null;
      }
    }
  },
  routes: [
    GoRoute(
      path: HomeScreen.routeName,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: EntryScreen.routeName,
      pageBuilder: (context, state) => NoTransitionPage<void>(
        key: state.pageKey,
        child: const EntryScreen(),
      ),
    ),
    GoRoute(
      path: ChatScreen.routeName,
      builder: (context, state) => const ChatScreen(),
    ),
    GoRoute(
      path: OpenChatScreen.routeName,
      builder: (context, state) => const OpenChatScreen(),
    ),
    GoRoute(
      path: ForumScreen.routeName,
      builder: (context, state) => const ForumScreen(),
    ),
    GoRoute(
      path: MeetupScreen.routeName,
      builder: (context, state) => const MeetupScreen(),
    ),
    GoRoute(
      path: BuyAndSellScreen.routeName,
      builder: (context, state) => const BuyAndSellScreen(),
    ),
    GoRoute(
      path: CustomChatScreen.routeName,
      builder: (context, state) => const CustomChatScreen(),
    ),
  ],
);
