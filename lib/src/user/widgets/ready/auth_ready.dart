import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// The user has logged in Firebase and the UID is ready.
///
/// Firebase Auth 에 로그인을 한 경우, builder(uid) 가 실행된다.
/// 만약, 로그인을 하지 않은 상태이면, notLogin() 이 실행된다.
///
/// 참고로, Firebase Realtime Database 의 사용자 문서가 로딩되지 않아도, Firebase Auth 에
/// 로그인이 되면 이 함수의 builder 가 실행된다.
class AuthReady extends StatelessWidget {
  const AuthReady({
    super.key,
    required this.builder,
    @Deprecated('Use notLoginBuilder instead') this.notLogin,
    this.notLoginBuilder,
  });

  final Widget Function(String) builder;

  final Widget? notLogin;

  final Widget Function()? notLoginBuilder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String?>(
      stream: FirebaseAuth.instance.authStateChanges().map((user) => user?.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.data == null) {
          if (notLoginBuilder != null) return notLoginBuilder!();
          return notLogin ?? const SizedBox.shrink();
        }
        return builder(snapshot.data!);
      },
    );
  }
}
