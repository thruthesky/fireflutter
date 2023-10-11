import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class PublicProfileScreen extends StatefulWidget {
  static const String routeName = '/public_profile';
  const PublicProfileScreen({super.key, this.uid, this.user});

  final String? uid;
  final User? user;

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  final BehaviorSubject<double?> progressEvent = BehaviorSubject<double?>.seeded(null);

  bool get isMyProfile =>
      loggedIn && (widget.uid == my.uid || widget.user?.uid == my.uid) || (widget.uid == null && widget.user == null);

  String? currentLoadedImageUrl;
  String previousUrl = '';

  @override
  void initState() {
    super.initState();
    if (isMyProfile) return;
    // Add view here
  }

  get textStyle => TextStyle(
        color: Theme.of(context).colorScheme.onSecondary,
      );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: Theme.of(context).colorScheme.background),
        doc(
          (user) => user.stateImageUrl.isEmpty
              ? Container(color: Theme.of(context).colorScheme.inverseSurface)
              : SizedBox.expand(
                  child: CachedNetworkImage(
                    imageUrl: user.stateImageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => previousUrl.isEmpty
                        ? const Center(child: CircularProgressIndicator.adaptive())
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
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: doc(
              (user) => AppBar(
                leading: IconButton(
                  key: const Key('PublicProfileBackButton'),
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                iconTheme: IconThemeData(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
                backgroundColor: Colors.transparent,
                title: Text(user.name, style: TextStyle(color: Theme.of(context).colorScheme.onSecondary)),
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
                  ...?UserService.instance.customize.publicScreenActions?.call(context, user),
                ],
              ),
            ),
          ),
          body: doc(
            (user) {
              if (!user.exists) {
                return Center(
                  child: Text(
                    'The user does not exist.',
                    style: TextStyle(color: Theme.of(context).colorScheme.onInverseSurface),
                  ),
                );
              }
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  StreamBuilder(
                      stream: progressEvent.stream,
                      builder: (context, snapshot) => snapshot.data == null
                          ? const SizedBox()
                          : LinearProgressIndicator(value: snapshot.data ?? 0)),
                  const SizedBox(height: sizeLg),
                  UserProfileAvatar(
                    user: user,
                    upload: isMyProfile,
                    size: 140,
                    radius: 54,
                  ),
                  const SizedBox(height: sizeLg),
                  Center(
                    child: Text(
                      user.state.ifEmpty(tr.noStateMessage),
                      style: textStyle,
                    ),
                  ),
                  const SizedBox(height: sizeLg),
                  Divider(
                    color: Theme.of(context).colorScheme.shadow.withAlpha(80),
                  ),
                  const SizedBox(height: sizeLg),
                  const LoginFirst(),
                  if (loggedIn) PublicProfileButtons(user: user),
                  const SafeArea(
                    child: SizedBox(height: sizeLg),
                  ),
                ],
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
