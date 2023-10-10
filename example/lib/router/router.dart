import 'package:go_router/go_router.dart';
import 'package:new_app/chat.room/chat.room.dart';
import 'package:new_app/forums/feed.dart';
import 'package:new_app/forums/land.page.dart';
import 'package:new_app/home.screen/main.page.dart';
import 'package:new_app/main.dart';

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
    )
  ],
);
