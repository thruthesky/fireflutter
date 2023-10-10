import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:new_app/home.screen/user.features/viewers.dart';
import 'package:new_app/page.essentials/simple.builders.dart';
import 'package:new_app/home.screen/user.features/followers.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  late String followers = my.followers.toList().length.toString();

  @override
  void initState() {
    super.initState();
    UserService.instance.get(myUid!);
    // UserService.instance.customize.
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return UserDocReady(
      builder: (user) => StreamBuilder(
        stream: UserService.instance.documentChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          List<String> followers = my.followers.toList();
          List<String> following = my.followings.toList();
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                userInfo(snapshot, context),
                const SizedBox(height: sizeLg),
                Text('Viewers: ${following.length}'),
                ProfileViewers(size: size),
                const SizedBox(height: sizeLg),
                Text('Followers: ${followers.length}'),
                ProfileFollowers(size: size, followers: followers),
                const Spacer(),
                buttonBuilder('Followers', () {
                  UserService.instance.showFollowersScreen(
                    context: context,
                    user: my,
                    itemBuilder: (user) => ListTile(
                      leading: UserAvatar(user: user),
                      title: Text(user.displayName),
                    ),
                  );
                }),
                buttonBuilder('Show Profile', () {
                  UserService.instance.showPublicProfileScreen(context: context, user: my);
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}





// class Followers extends StatelessWidget {
//   const Followers({
//     super.key,
//     required this.followers,
//   });

//   final List<String> followers;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: appBar('Followers', hasLeading: true, hasActions: false),
//       body: ListView.builder(
//         itemCount: followers.length,
//         itemBuilder: (context, i) => UserDoc(
//             uid: followers[i],
//             builder: (follower) {
//               return ListTile(
//                 onTap: () => UserService.instance.showPublicProfileScreen(context: context, user: follower),
//                 leading: UserAvatar(
//                   user: follower,
//                   size: sizeXl,
//                 ),
//                 title: Text(follower.name),
//                 trailing: const FaIcon(FontAwesomeIcons.chevronRight),
//               );
//             }),
//       ),
//     );
//   }
// }
/// display category
// const Text('Categories'),
// const Expanded(
//   child: CategoryListView(),
// ),