import 'package:go_router/go_router.dart';
import 'package:new_app/login/login.page.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: LoginPageBody(),
      ),
    ),
  ],
);
