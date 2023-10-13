import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:new_app/home/user_profile/user.features/viewers.dart';
import 'package:new_app/page.essentials/simple.builders.dart';
import 'package:new_app/home/user_profile/user.features/followers.dart';
import 'package:new_app/router/router.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  late String followers = my!.followers.toList().length.toString();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      FireFlutterService.instance.init(context: router.routerDelegate.navigatorKey.currentContext!);
    });
  }

  final test = ChatService.instance;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return UserDoc(builder: (user) {
      List<String> followers = user.followers.toList();
      List<String> following = user.followings.toList();
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            userInfo(user, context),
            const SizedBox(height: sizeLg),
            Text('Viewers: ${following.length}'),
            ProfileViewers(size: size),
            const SizedBox(height: sizeLg),
            Text('Followers: ${followers.length}'),
            ProfileFollowers(size: size, followers: followers),
            const Spacer(),
            SizedBox(
              height: size.height / 6 - 10,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    buttonBuilder('Followers', () {
                      UserService.instance.showFollowersScreen(
                        context: context,
                        user: user,
                        itemBuilder: (user) => ListTile(
                          leading: UserAvatar(user: user),
                          title: Text(user.displayName),
                        ),
                      );
                    }),
                    buttonBuilder('Show Profile', () {
                      UserService.instance.showPublicProfileScreen(context: context, user: my);
                    }),
                    buttonBuilder(
                      'Show Admin Dashboard',
                      () => AdminService.instance.showDashboard(context: context),
                    ),
                    buttonBuilder(
                      'Show Admin User List View',
                      () => showDialog(
                        context: context,
                        builder: (cnx) => const Dialog(
                          child: AdminUserListView(),
                        ),
                      ),
                    ),
                    buttonBuilder(
                      'Show Category List View',
                      () => showDialog(
                        context: context,
                        builder: (cnx) => Dialog(
                          child: CategoryListView(
                            onTap: (cat) => CategoryService.instance.showUpdateDialog(context, cat.id),
                          ),
                        ),
                      ),
                    ),
                    buttonBuilder(
                      'Show Category Create',
                      () => showDialog(
                        context: context,
                        builder: (cnx) => CategoryCreateScreen(
                          success: (cat) => debugPrint('$cat'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      );
    });
  }
}
