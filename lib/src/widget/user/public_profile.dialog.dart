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

  bool get isMyProfile => widget.uid == my.uid;

  String? currentLoadedImageUrl;
  String previousUrl = '';

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: Theme.of(context).colorScheme.background),
        doc(
          (user) => user.stateImageUrl.isEmpty
              ? const SizedBox.shrink()
              : SizedBox.expand(
                  child: CachedNetworkImage(
                    imageUrl: user.stateImageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => previousUrl.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : CachedNetworkImage(
                            imageUrl: previousUrl,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withAlpha(100), Colors.transparent],
                end: Alignment.bottomCenter,
                begin: Alignment.topCenter,
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: 150,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: doc((user) => Text(user.name, style: TextStyle(color: Theme.of(context).colorScheme.secondary))),
            actions: [
              if (isMyProfile)
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
                    previousUrl = my.stateImageUrl;
                    my.update(stateImageUrl: url);
                    if (previousUrl.isNotEmpty) {
                      Timer(const Duration(seconds: 2), () => StorageService.instance.delete(previousUrl));
                    }
                  },
                  icon: const Icon(Icons.camera_alt),
                ),
            ],
          ),
          body: doc(
            (user) {
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
                          UserProfileAvatar(
                            user: user,
                            upload: isMyProfile,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton(
                                onPressed: () async {
                                  await user.like();
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                ),
                                child: Text(user.noOfLikes),
                              ),
                              TextButton(
                                onPressed: () {
                                  Favorite.toggle(otherUid: widget.uid);
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                ),
                                child: const Text("Favorite"),
                              ),
                              TextButton(
                                onPressed: () {
                                  ChatService.instance.showChatRoom(context: context, user: user);
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                ),
                                child: const Text("Chat"),
                              ),
                            ],
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

  doc(Function(User) builder) {
    return UserDoc(
      // The background doesn't have to be live if it is not me
      live: isMyProfile,
      uid: widget.uid,
      user: widget.user,
      builder: (user) => builder(user),
    );
  }
}
