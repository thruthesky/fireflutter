import 'package:fireflutter/fireflutter.dart' hide PublicProfileScreen;
import 'package:flutter/material.dart';

class NewUserHorizontalList extends StatelessWidget {
  const NewUserHorizontalList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: UserListView(
        scrollDirection: Axis.horizontal,
        pageSize: 20,
        itemBuilder: (User user, int index) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            debugPrint("---> $user");
            UserService.instance.showPublicProfileScreen(context: context, user: user);
          },
          child: Container(
            width: 56,
            margin: EdgeInsets.only(left: index == 0 ? 16 : 0),
            child: Column(
              children: [
                UserAvatar(
                  user: user,
                  size: 42,
                  radius: 16,
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 42,
                  child: Center(
                    child: Text(
                      user.name,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Theme.of(context).colorScheme.secondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
