import 'package:fireflutter/fireflutter.dart';
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
                title: Text("${T.name.tr}: ${user.displayName}"),
                subtitle: Text("UID: ${user.uid}"),
              ),
              CheckboxListTile(
                value: user.isVerified,
                title: Text(T.userAuthentication.tr),
                subtitle: Text(
                  user.isVerified
                      ? T.userHasBeenAuthenticated.tr
                      : T.authenticateUser.tr,
                ),
                onChanged: (value) async {
                  await user.update(isVerified: value);
                  await user.reload();
                  if (context.mounted) {
                    alert(
                      context: context,
                      title: T.userAuthentication.tr,
                      message:
                          '${T.userAuthentication.tr} ${user.isVerified == true ? T.complete.tr : T.removed.tr}',
                    );
                  }
                },
              ),
              CheckboxListTile(
                value: user.isDisabled,
                title: Text(T.blockUser.tr),
                subtitle: Text(
                  user.isDisabled
                      ? T.confirmUnblockThisUser.tr
                      : T.confirmBlockThisUser.tr,
                ),
                onChanged: (value) async {
                  if (user.isDisabled == true) {
                    await user.enable();
                  } else {
                    await user.disable();
                  }
                  await user.reload();
                  if (context.mounted) {
                    error(
                      context: context,
                      title: T.blockUser.tr,
                      message:
                          '${T.blockUser.tr} ${user.isDisabled == true ? T.complete.tr : T.removed.tr}',
                    );
                  }
                },
              ),
              CheckboxListTile(
                value: AdminService.instance.checkAdmin(user.uid),
                title: Text(T.adminSetting.tr),
                subtitle: Text(
                  AdminService.instance.checkAdmin(user.uid)
                      ? T.confirmRemoveAdminPrevilege.tr
                      : T.confirmSetAdminPrevilege.tr,
                ),
                onChanged: (value) async {
                  // await user.update(isAdmin: value);
                  // await user.reload();
                  // await AdminService.instance.setAdmin(user.uid, value);
                  // if (context.mounted) {
                  //   error(
                  //     context: context,
                  //     title: '관리자 ${isAdmin == true ? '지정' : '해제'}',
                  //     message:
                  //         '관리자 ${isAdmin == true ? '관리자로 지정되었습니다.' : '관리자 권한 해제되었습니다.'}',
                  //   );
                  // }
                  alert(
                    context: context,
                    title: T.adminSetting.tr,
                    message: T.adminSetupMessage.tr,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
