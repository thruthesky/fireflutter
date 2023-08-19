import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class UserPublicProfileDialog extends StatefulWidget {
  const UserPublicProfileDialog({super.key, required this.user});

  final User user;

  @override
  State<UserPublicProfileDialog> createState() => _UserPublicProfileDialogState();
}

class _UserPublicProfileDialogState extends State<UserPublicProfileDialog> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: UserService.instance.listen(widget.user.uid),
      builder: (context, snapshot) {
        User user = widget.user;
        if (snapshot.hasData) user = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: Text(user.displayName),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body: Column(
            children: [
              const SizedBox(height: 16),
              UserAvatar(
                user: user,
                size: 128,
              ),
              Center(
                child: Text(user.firstName),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text('Chat'),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Like'),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Follow'),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Report'),
                  ),
                  PopupMenuButton(
                    itemBuilder: (context) {
                      return [
                        const PopupMenuItem(
                          value: 'block',
                          child: Text('Block'),
                        ),
                        const PopupMenuItem(
                          value: 'report',
                          child: Text('Report'),
                        ),
                      ];
                    },
                    onSelected: (value) {
                      if (value == 'block') {
                        // UserService.instance.blockUser(user.uid);
                        // user.block();
                      } else if (value == 'report') {
                        // UserService.instance.reportUser(user.uid);
                        // ReportService.instance.profile(user.uid);
                      }
                    },
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
