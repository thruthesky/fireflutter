import 'package:cloud_firestore/cloud_firestore.dart';
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = snapshot.data;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: const Text('Public Profile'),
          ),
          body: user == null
              ? const Center(child: Text("User not found"))
              : Column(
                  children: [
                    const Center(
                      child: Text('Public Profile'),
                    ),
                    const SizedBox(height: 20),
                    UserDoc(
                        uid: uid,
                        live: true,
                        builder: (otherUser) {
                          return ElevatedButton(
                            onPressed: () async {
                              await otherUser.like();
                            },
                            child: Text(otherUser.noOfLikes),
                          );
                        }),
                    ElevatedButton(
                      onPressed: () {
                        Favorite.toggle(type: FavoriteType.user, otherUid: uid);
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
