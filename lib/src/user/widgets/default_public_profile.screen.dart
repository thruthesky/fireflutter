import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class DefaultPublicProfileScreen extends StatelessWidget {
  const DefaultPublicProfileScreen({super.key, required this.uid});

  final String uid;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: UserDoc(
              uid: uid,
              field: Field.profileBackgroundImageUrl,
              builder: (url) => CachedNetworkImage(
                imageUrl: url ?? 'https://picsum.photos/id/171/400/900',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 220,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black54,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 220,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black54,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Column(
            children: [
              SafeArea(
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isIos ? Icons.arrow_back_ios : Icons.arrow_back,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    if (uid == myUid)
                      IconButton(
                        icon: const Icon(
                          Icons.settings_outlined,
                          color: Colors.white,
                        ),
                        onPressed: () => UserService.instance.showProfile(context),
                      ),
                  ],
                ),
              ),
              const Spacer(),
              UserAvatar(uid: uid, size: 100, radius: 40),
              const SizedBox(height: 8),
              UserDoc(
                uid: uid,
                builder: (data) {
                  if (data == null) return const SizedBox.shrink();
                  final user = UserModel.fromJson(data, uid: uid);
                  return Column(
                    children: [
                      Text(
                        user.displayName,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        user.stateMessage,
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                              color: Colors.white.withAlpha(200),
                            ),
                      ),
                    ],
                  );
                },
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          ChatService.instance.showChatRoom(context: context, uid: uid);
                        },
                        child: Text(T.chat.tr),
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
                          await ReportService.instance.report(otherUserUid: uid, reason: re);
                        },
                        child: Text(T.report.tr),
                      ),

                      /// 차단 & 해제
                      MyDoc.field('${Field.blocks}/$uid', builder: (v) {
                        return ElevatedButton(
                          onPressed: () async {
                            final re = await confirm(
                              context: context,
                              title: v == null ? T.blockConfirmTitle.tr : T.unblockConfirmTitle.tr,
                              message:
                                  v == null ? T.blockConfirmMessage.tr : T.unblockConfirmMessage.tr,
                            );
                            if (re != true) return;
                            await my?.block(uid);
                          },
                          child: Text(v == null ? T.block.tr : T.unblock.tr),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
