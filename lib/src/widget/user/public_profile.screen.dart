import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class PublicProfileScreen extends StatefulWidget {
  const PublicProfileScreen({super.key, this.uid, this.user});

  final String? uid;
  final User? user;

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  final BehaviorSubject<double?> progressEvent =
      BehaviorSubject<double?>.seeded(null);

  bool get isMyProfile => loggedIn && widget.uid == my.uid;

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
                        ? const Center(
                            child: CircularProgressIndicator.adaptive())
                        : CachedNetworkImage(
                            imageUrl: previousUrl,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
        ),
        const TopDownGraident(height: 200),
        const BottomUpGraident(height: 300),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: doc((user) => Text(user.name,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondary))),
            actions: [
              if (isMyProfile)
                IconButton(
                  style: IconButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    backgroundColor:
                        Theme.of(context).colorScheme.secondary.withAlpha(200),
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
                      Timer(const Duration(seconds: 2),
                          () => StorageService.instance.delete(previousUrl));
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
                              builder: (context, snapshot) =>
                                  snapshot.data == null
                                      ? const SizedBox()
                                      : LinearProgressIndicator(
                                          value: snapshot.data ?? 0)),
                          const Center(
                            child: Text('Public Profile'),
                          ),
                          const SizedBox(height: 20),
                          UserProfileAvatar(
                            user: user,
                            upload: isMyProfile,
                          ),
                          const SizedBox(height: 20),
                          if (loggedIn)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton(
                                  style: TextButton.styleFrom(
                                      foregroundColor: Theme.of(context)
                                          .colorScheme
                                          .onSecondary),
                                  onPressed: () => like(user.uid),
                                  child: Database(
                                    path: 'likes/${user.uid}',
                                    builder: (value) => Text(value == null
                                        ? 'Like'
                                        : '${(value as Map).length} Likes'),
                                  ),
                                ),
                                FavoriteButton(
                                  otherUid: user.uid,
                                  builder: (re) => Text(
                                    re ? 'Unfavorite' : 'Favorite',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondary,
                                    ),
                                  ),
                                  onChanged: (re) => toast(
                                    title: re ? 'Favorite' : 'Unfavorite',
                                    message: re
                                        ? 'You have favorited this user.'
                                        : 'You have unfavorited this user.',
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    ChatService.instance.showChatRoom(
                                      context: context,
                                      user: user,
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Theme.of(context)
                                        .colorScheme
                                        .onSecondary,
                                  ),
                                  child: const Text("Chat"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    final blocked = await toggle(
                                        '/settings/$myUid/blocks/${user.uid}');
                                    toast(
                                        title:
                                            blocked ? 'Blocked' : 'Unblocked',
                                        message:
                                            'The user has been ${blocked ? 'blocked' : 'unblocked'} by you');
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Theme.of(context)
                                        .colorScheme
                                        .onSecondary,
                                  ),
                                  child: Database(
                                    path: 'settings/$myUid/blocks/${user.uid}',
                                    builder: (value) => Text(
                                        value == null ? 'Block' : 'Unblock'),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    ReportService.instance.showReportDialog(
                                      context: context,
                                      otherUid: user.uid,
                                      onExists: (id, type) => toast(
                                          title: 'Already reported',
                                          message:
                                              'You have reported this $type already.'),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Theme.of(context)
                                        .colorScheme
                                        .onSecondary,
                                  ),
                                  child: const Text('Report'),
                                ),
                              ],
                            ),
                          if (notLoggedIn)
                            TextButton(
                              onPressed: () {
                                toast(
                                  title: tr.user.loginFirstTitle,
                                  message: tr.user.loginFirstMessage,
                                );
                              },
                              child: Text(tr.user.loginFirstMessage),
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
