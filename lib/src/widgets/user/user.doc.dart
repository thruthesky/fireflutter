import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// UserDoc
///
/// builder: 로그인이 되어있고, 사용자 문서가 존재 할 때, 빌드 할 위젯
///
/// notLoggedInBuilder: 로그인이 되어있지 않을 때, 빌드할 위젯. 콜백 함수가 지정되지 않으면 빈 위젯을 빌드한다.
///
/// documentNotExistBuilder: 사용자가 로그인이 되어있으나, /users/{uid} 에 사용자 문서가 존재하지 않을 때
/// 빌드할 위젯. 이 경우, 사용자문서를 생성 할 수 있다. 콜백 함수가 지저오디지 않으면, 빈 위젯을 빌드한다.
///
///
///
class UserDoc extends StatelessWidget {
  const UserDoc(
      {super.key, required this.builder, this.notLoggedInBuilder, this.documentNotExistBuilder});
  final Widget Function(UserModel) builder;
  final Widget Function()? notLoggedInBuilder;
  final Widget Function()? documentNotExistBuilder;

  @override
  Widget build(BuildContext context) {
    return UserReady(builder: (user) {
      /// 사용자 로그인 하지 않은 경우,
      if (user == null) {
        if (notLoggedInBuilder != null) {
          return notLoggedInBuilder!();
        } else {
          return const SizedBox.shrink();
        }
      }

      return StreamBuilder(
        stream: UserService.instance.doc.snapshots(),
        builder: (_, snapshot) {
          /// 주의: 반짝임(깜빡거림)이 발생할 수 있다.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox.shrink();
          }

          final docSnapshot = snapshot.data as DocumentSnapshot;

          /// 사용자 문서가 존재하지 않는 경우,
          if (!docSnapshot.exists || docSnapshot.data() == null) {
            if (documentNotExistBuilder != null) {
              return documentNotExistBuilder!();
            } else {
              return const SizedBox.shrink();
            }
          }

          /// 로그인 했고, 사용자 문서가 존재하는 경우,
          return builder(UserModel.fromDocumentSnapshot(docSnapshot));
        },
      );
    });
  }
}
