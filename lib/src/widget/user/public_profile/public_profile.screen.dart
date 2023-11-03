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
      loggedIn && (widget.uid == myUid || widget.user?.uid == myUid) || (widget.uid == null && widget.user == null);

  String? currentLoadedImageUrl;
  String previousUrl = '';

  TextStyle get textStyle => TextStyle(
        // changing the color from onBackground to onInverseSurface(90) to make the text readable on together with
        // background image and gradient. because the text color onbackground is changing from white(light mode) to black(darkmode)
        // and when its on darkmode the text color is also black so it is not readable on darkmode
        color: Theme.of(context).colorScheme.onInverseSurface.tone(90),
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
        TopDownGraident(
          height: 300,
          colors: [
            Theme.of(context).colorScheme.inverseSurface.tone(10),
            Colors.transparent,
          ],
        ),
        BottomUpGraident(height: 300, colors: [
          Theme.of(context).colorScheme.inverseSurface.tone(10),
          Colors.transparent,
        ]),
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
                  color: Theme.of(context).colorScheme.onInverseSurface.tone(90),
                ),
                backgroundColor: Colors.transparent,
                title: Text(user.name, style: textStyle),
                actions: [
                  if (isMyProfile)
                    IconButton(
                      key: const Key('PublicProfileCameraButton'),
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
                        previousUrl = my!.stateImageUrl;
                        my?.update(stateImageUrl: url);
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
                  child: Text('The user does not exist.', style: textStyle),
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
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.75,
                    child: Center(
                      child: user.uid == myUid
                          ? TextButton(
                              child: RichText(
                                text: TextSpan(
                                  style: textStyle,
                                  children: [
                                    TextSpan(text: '${user.state.ifEmpty(tr.noStateMessage)} '),
                                    WidgetSpan(
                                      child: Icon(
                                        Icons.edit,
                                        size: 18,
                                        color: Theme.of(context).colorScheme.onInverseSurface.tone(90),
                                      ),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              onPressed: () async {
                                final newState = await prompt(
                                  context: context,
                                  title: tr.stateMessage,
                                  hintText: tr.howAreYouToday,
                                  initialValue: user.state,
                                );
                                if (newState == null) return;
                                await user.update(state: newState);
                                if (!mounted) return;
                                setState(() {});
                              },
                            )
                          : Text(
                              user.state,
                              style: textStyle,
                              textAlign: TextAlign.center,
                            ),
                    ),
                  ),
                  const SizedBox(height: sizeLg),
                  Divider(
                    color: Theme.of(context).colorScheme.onInverseSurface.tone(90),
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

// The background doesn't have to be live if it is not me
  doc(Function(User) builder) {
    if (isMyProfile) return MyDoc(builder: (user) => builder(user));

    return UserDoc(
      uid: widget.uid ?? widget.user!.uid,
      builder: (user) => builder(user),
    );
  }
}
