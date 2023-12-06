import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// MyDoc
///
/// myDoc is a wrapper widget of UserDoc widget.
///
/// For the first time, it may take time to get the event data from BehaverSubject.
/// But the second time and on, there is no delay. So, [onLoading] is optional.
class MyDoc extends StatelessWidget {
  const MyDoc({
    super.key,
    required this.builder,
    this.onLoading,
  });

  final Widget Function(User) builder;
  final Widget? onLoading;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: UserService.instance.documentChanges,
      builder: (context, snapshot) => buildStreamWidget(context, snapshot),
    );
  }

  Widget buildStreamWidget(BuildContext _, AsyncSnapshot<User?> snapshot) {
    /// 주의: 로딩 중, 반짝임(깜빡거림)이 발생할 수 있다.
    if (snapshot.connectionState == ConnectionState.waiting) {
      // This is to prevent loading when the widget is rebuilt.
      // StreamBuilder always begins with a ConnectionState.waiting.
      // Please change the logic because there might be a better way
      return UserService.instance.documentChanges.value != null
          ? builder(UserService.instance.documentChanges.value!)
          : onLoading ?? const SizedBox.shrink();
    }

    final userModel = snapshot.data;

    /// Warning, the user data may be empty even if the user logged in.
    ///
    /// If the app is using [MyDoc] too early before the user service
    /// gets data from firestore, it will return [User.nonExistent] which may
    /// cause empty data of the user even if the user logged in.
    ///
    /// Or if the userModel is null, it means, the app just started and the user has not logged in yet or in the middle of login.
    ///
    /// In these case, a user object with exists=false is passed to the builder.
    if (snapshot.hasData == false || userModel == null) {
      ///
      /// It passes the user model with the current time when there is no user document.
      return builder(User.nonExistent());
    }
    return builder(userModel);
  }
}
