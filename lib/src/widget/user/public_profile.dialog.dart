import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PublicProfileDialog extends StatelessWidget {
  const PublicProfileDialog({super.key, required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: UserService.instance.get(uid),
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: const Text('Public Profile'),
          ),
          body: Column(
            children: [
              const Center(
                child: Text('Public Profile'),
              ),
              const SizedBox(height: 20),
              UserDoc(
                live: true,
                builder: (user) => ElevatedButton(
                  onPressed: () {
                    my.like(user.uid);
                  },
                  child: Text(user.noOfLikes),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Favorite.create(type: FavoriteType.user, otherUid: uid);
                },
                child: const Text("Favorite"),
              ),
            ],
          ),
        );
      },
    );
  }
}
