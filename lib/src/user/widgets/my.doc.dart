import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// 나의 문서 `/users/<uid>` 를 listen 하고 업데이트가 있으면 build 함수를 호출한다.
///
/// 사용자 로그인을 하지 않았거나, 사용자 문서가 존재하지 않으면,
///   builder 파라메타로 전달되는 userModel 은 UserService.instance.user 이며,
///   기본적으로 UserModel() 을 값을 가진다. 이 때, uid 는 empty string 이다.
/// 사용자가 로그 아웃이나 계정을 변경해도 이전 사용자 문서 listen 을 cancel 하고 새로 로그인한 사용자의 문서를 잘 listen 한다.
/// 사용자가 로그인을 한 상태에서 로그아웃을 하면, [builder] 를  한 번 더 실행(렌더링)하는데,
///   이 때, 파라메타는 빈 사용자 모델이다.

class MyDoc extends StatelessWidget {
  const MyDoc({Key? key, required this.builder}) : super(key: key);
  final Widget Function(UserModel) builder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: UserService.instance.userChange,
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return SizedBox.shrink();
        if (snapshot.hasError) return Text(snapshot.error.toString());

        return builder(snapshot.data as UserModel);
      },
    );
  }
}

// class MyDoc extends StatefulWidget {
//   const MyDoc({
//     Key? key,
//     required this.builder,
//   }) : super(key: key);
//   final Widget Function(UserModel) builder;

//   @override
//   State<MyDoc> createState() => _MyDocState();
// }

// class _MyDocState extends State<MyDoc> {
//   UserModel userModel = UserModel();
//   StreamSubscription? userDocumentSubscription;
//   late StreamSubscription authSubscription;

//   @override
//   void initState() {
//     super.initState();

//     authSubscription =
//         Firebase.FirebaseAuth.instance.authStateChanges().listen((user) {
//       userDocumentSubscription?.cancel();
//       userDocumentSubscription = UserService.instance.doc
//           .snapshots()
//           .listen((DocumentSnapshot snapshot) async {
//         userModel = UserModel.fromSnapshot(snapshot);
//         setState(() {});
//       });
//     });
//   }

//   @override
//   void dispose() {
//     userDocumentSubscription?.cancel();
//     authSubscription.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return this.widget.builder(userModel);
//   }
// }
