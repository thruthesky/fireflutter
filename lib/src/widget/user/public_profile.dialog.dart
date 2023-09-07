import 'dart:async';

import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class PublicProfileDialog extends StatefulWidget {
  const PublicProfileDialog({super.key, this.uid, this.user});

  final String? uid;
  final User? user;

  @override
  State<PublicProfileDialog> createState() => _PublicProfileDialogState();
}

class _PublicProfileDialogState extends State<PublicProfileDialog> {
  final BehaviorSubject<double?> progressEvent = BehaviorSubject<double?>.seeded(null);

  bool get isItMe => widget.uid == my.uid;

  String? currentLoadedImageUrl;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        UserDoc(
          // The background doesn't have to be live if it is not me
          live: isItMe,
          uid: widget.uid,
          builder: (user) {
            return CachedNetworkImage(
              // Transition is a bit difficult because the UserDoc clears and rebuilds this part
              fadeInDuration: Duration.zero,
              fadeOutDuration: Duration.zero,
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
              alignment: Alignment.center,
              imageUrl:
                  user.stateImageUrl.isEmpty ? "https://picsum.photos/id/${user.birthDay}/600/400" : user.stateImageUrl,
              cacheKey:
                  user.stateImageUrl.isEmpty ? "https://picsum.photos/id/${user.birthDay}/600/400" : user.stateImageUrl,
              progressIndicatorBuilder: (context, str, progress) {
                currentLoadedImageUrl ??= user.stateImageUrl;
                log('Downloading ${progress.totalSize}/${progress.downloaded}');
                if (progress.totalSize == progress.downloaded) {
                  log('Should update previous URL. current url: $currentLoadedImageUrl');
                  // This should happen last
                  String previousUrl = currentLoadedImageUrl!;
                  currentLoadedImageUrl = user.stateImageUrl;
                  return CachedNetworkImage(
                    fadeInDuration: Duration.zero,
                    fadeOutDuration: Duration.zero,
                    fit: BoxFit.cover,
                    height: double.infinity,
                    width: double.infinity,
                    alignment: Alignment.center,
                    imageUrl: previousUrl,
                    cacheKey: previousUrl,
                  );
                }
                return CachedNetworkImage(
                  fadeInDuration: Duration.zero,
                  fadeOutDuration: Duration.zero,
                  fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
                  alignment: Alignment.center,
                  imageUrl: currentLoadedImageUrl!,
                  cacheKey: currentLoadedImageUrl!,
                );
              },
            );
          },
          // For confirmation, should we add onReloading so that we can have better transition?
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: UserDoc(
              live: isItMe,
              builder: (user) {
                return Text(user.name, style: TextStyle(color: Theme.of(context).colorScheme.secondary));
              },
            ),
            actions: [
              if (isItMe)
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
          body: UserDoc(
            live: false,
            builder: (user) {
              return user.exists == false
                  ? const Center(child: Text("User not found"))
                  : SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
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
                            live: isItMe,
                            builder: (user) {
                              return UserProfileAvatar(
                                user: user,
                                upload: isItMe,
                              );
                            },
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
                            },
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Favorite.toggle(otherUid: widget.uid);
                            },
                            child: const Text("Favorite"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              ChatService.instance.showChatRoom(context: context, user: user);
                            },
                            child: const Text("Chat"),
                          ),
                        ],
                      ),
                    );
            },
          ),
        ),
      ],
    );
  }
}
