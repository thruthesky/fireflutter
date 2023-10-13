import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfileFollowers extends StatelessWidget {
  const ProfileFollowers({
    super.key,
    required this.size,
    required this.followers,
  });

  final Size size;
  final List<String> followers;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size.height / 6,
      child: followers.isEmpty
          ? const Text('No Followers')
          : UserListView.builder(
              uids: followers,
              itemBuilder: (user) => ListTile(
                leading: UserAvatar(user: user),
                title: Text(user!.name),
                trailing: IconButton(
                  onPressed: () async {
                    final blocked = await toggle(pathBlock(user.uid));
                    toast(
                        title: blocked ? 'Blocked' : 'Unblocked',
                        message: '${user.name} has been ${blocked ? 'blocked' : 'unblocked'}.');
                  },
                  icon: const FaIcon(FontAwesomeIcons.ban),
                ),
              ),
            ),
    );
  }
}
