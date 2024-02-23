import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireship/fireship.dart';
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
          child: UserDoc.field(
            uid: userUid,
            initialData: user?.profileBackgroundImageUrl,
            field: Field.profileBackgroundImageUrl,
            builder: (url) => CachedNetworkImage(
              imageUrl: url ?? 'https://picsum.photos/id/171/400/900',
              fit: BoxFit.cover,
            ),
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
                UserAvatar(uid: userUid, size: 100, radius: 40),
                const SizedBox(height: 8),
                UserDisplayName(
                  uid: userUid,
                  user: user,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                UserStateMessage(
                  uid: userUid,
                  user: user,
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: Colors.white.withAlpha(200),
                      ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Wrap(
                      children: [
                        // Chat
                        ElevatedButton(
                          onPressed: () async {
                            ChatService.instance.showChatRoom(
                              context: context,
                              uid: userUid,
                            );
                          },
                          child: Text(T.chat.tr),
                        ),

                        LikeButton(
                          uid: userUid,
                          user: user,
                        ),

                        // Bookmark
                        Value(
                          path: Path.bookmarkUser(userUid),
                          builder: (v) => ElevatedButton(
                            onPressed: () async {
                              if (v != null) {
                                await BookmarkModel.delete(
                                    otherUserUid: userUid);
                              } else {
                                await BookmarkModel.create(
                                    otherUserUid: userUid);
                              }
                            },
                            child: Text(
                              v == null ? T.bookmark.tr : T.bookmarked.tr,
                            ),
                          ),
                        ),

                        /// 레포팅 신고
                        ElevatedButton(
                          onPressed: () async {
                            final re = await input(
                              context: context,
                              title: T.reportInputTitle.tr,
                              subtitle: T.reportInputMessage.tr,
                              hintText: T.reportInputHint.tr,
                            );
                            if (re == null || re == '') return;
                            await ReportService.instance
                                .report(otherUserUid: userUid, reason: re);
                          },
                          child: Text(T.report.tr),
                        ),

                        /// 차단 & 해제
                        MyDoc.field(
                          '${Field.blocks}/$userUid',
                          builder: (v) {
                            return ElevatedButton(
                              onPressed: () async {
                                final re = await confirm(
                                  context: context,
                                  title: v == null
                                      ? T.blockConfirmTitle.tr
                                      : T.unblockConfirmTitle.tr,
                                  message: v == null
                                      ? T.blockConfirmMessage.tr
                                      : T.unblockConfirmMessage.tr,
                                );
                                if (re != true) return;
                                await my?.block(userUid);
                              },
                              child:
                                  Text(v == null ? T.block.tr : T.unblock.tr),
                            );
                          },
                        ),
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
