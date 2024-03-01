import 'dart:io';

import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class DefaultPublicProfileScreen extends StatelessWidget {
  const DefaultPublicProfileScreen({super.key, this.uid, this.user});

  final String? uid;
  final UserModel? user;

  String get userUid => uid ?? user!.uid;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: UserBackgroundImage.sync(
            uid: userUid,
            user: user,
          ),
        ),
        const GradientTopDown(height: 220),
        const GradientBottomUp(height: 220),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              if (userUid == myUid)
                IconButton(
                  icon: const Icon(
                    Icons.settings_outlined,
                    color: Colors.white,
                  ),
                  onPressed: () =>
                      UserService.instance.showProfileScreen(context),
                ),
              const SizedBox(width: 8),
            ],
          ),
          body: Center(
            child: Column(
              children: [
                const Spacer(),
                UserAvatar.sync(uid: userUid, size: 100, radius: 40),
                const SizedBox(height: 8),
                UserDisplayName.sync(
                  uid: userUid,
                  user: user,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                UserStateMessage.sync(
                  uid: userUid,
                  user: user,
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Wrap(
                      children: [
                        ChatButton(uid: uid),
                        LikeButton(uid: userUid, user: user),
                        BookmarkButton(uid: userUid),
                        ReportButton(uid: userUid),
                        BlockButton(uid: userUid),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
