import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class PublicProfileDialog extends StatefulWidget {
  const PublicProfileDialog({super.key, required this.uid});

  final String uid;

  @override
  State<PublicProfileDialog> createState() => _PublicProfileDialogState();
}

class _PublicProfileDialogState extends State<PublicProfileDialog> {
  final BehaviorSubject<double?> progressEvent = BehaviorSubject<double?>.seeded(null);

  @override
  Widget build(BuildContext context) {
    return UserDoc(
      live: true,
      builder: (user) {
        // CachedNetworkImage()
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            image: DecorationImage(
              image: CachedNetworkImageProvider(
                user.stateImageUrl.isEmpty ? "https://picsum.photos/id/${user.birthDay}/600/400" : user.stateImageUrl,
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: Text(user.name, style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
              actions: [
                IconButton(
                  style: IconButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    backgroundColor: Theme.of(context).colorScheme.secondary.withAlpha(200),
                  ),
                  onPressed: () async {
                    final url = await StorageService.instance.upload(
                      context: context,
                      file: false,
                      progress: (p) => progressEvent.add(p),
                      complete: () => progressEvent.add(null),
                    );
                    final previousUrl = my.stateImageUrl;
                    my.update(stateImageUrl: url);
                    if (previousUrl.isNotEmpty) {
                      Timer(const Duration(seconds: 2), () => StorageService.instance.delete(previousUrl));
                    }
                  },
                  icon: const Icon(Icons.camera_alt),
                ),
              ],
            ),
            body: user.exists == false
                ? const Center(child: Text("User not found"))
                : Column(
                    children: [
                      StreamBuilder(
                          stream: progressEvent.stream,
                          builder: (context, snapshot) => snapshot.data == null
                              ? const SizedBox()
                              : LinearProgressIndicator(value: snapshot.data ?? 0)),
                      const Center(
                        child: Text('Public Profile'),
                      ),
                      const SizedBox(height: 20),
                      UserDoc(
                          uid: widget.uid,
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
                          Favorite.toggle(otherUid: widget.uid);
                        },
                        child: const Text("Favorite"),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
