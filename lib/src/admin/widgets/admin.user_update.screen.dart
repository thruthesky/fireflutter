import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class AdminUserUpdateScreen extends StatefulWidget {
  const AdminUserUpdateScreen({super.key, required this.uid});

  final String uid;

  @override
  State<AdminUserUpdateScreen> createState() => _AdminUserUpdateScreenState();
}

class _AdminUserUpdateScreenState extends State<AdminUserUpdateScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Update'),
      ),
      body: UserDoc.sync(
        uid: widget.uid,
        builder: (user) {
          return Column(
            children: [
              ListTile(
                title: Text("이름: ${user.displayName}"),
                subtitle: Text("UID: ${user.uid}"),
              ),
              CheckboxListTile(
                value: user.isVerified,
                title: const Text('사용자 인증'),
                subtitle: Text(user.isVerified
                    ? '인증이 완료된 사용자입니다.'
                    : '인증되지 않았습니다. 인증된 사용자로 전환 하시겠습니까?'),
                onChanged: (value) async {
                  await user.update(isVerified: value);
                  await user.reload();
                  if (context.mounted) {
                    error(
                      context: context,
                      title: '사용자 인증 ${user.isVerified == true ? '완료' : '해제'}',
                      message:
                          '사용자 인증 ${user.isVerified == true ? '완료되었습니다.' : '해제되었습니다.'}',
                    );
                  }
                },
              ),
              CheckboxListTile(
                value: user.isAdmin,
                title: const Text('관리자 설정'),
                subtitle: Text(user.isAdmin
                    ? '관리자입니다. 관리자 권한을 해제하시겠습니까?'
                    : '관리자로 설정하시겠습니까?'),
                onChanged: (value) async {
                  await user.update(isAdmin: value);
                  await user.reload();
                  if (context.mounted) {
                    error(
                      context: context,
                      title: '관리자 ${user.isAdmin == true ? '지정' : '해제'}',
                      message:
                          '관리자 ${user.isAdmin == true ? '관리자로 지정되었습니다.' : '관리자 권한 해제되었습니다.'}',
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
