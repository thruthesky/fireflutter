import 'package:fireflutter/fireflutter.dart';

import 'package:flutter/material.dart';

class MeetupBlockedMembersScreen extends StatelessWidget {
  const MeetupBlockedMembersScreen({
    super.key,
    required this.meetup,
    this.padding,
    this.separatorBuilder,
  });

  final Meetup meetup;
  final EdgeInsets? padding;
  final Widget Function(BuildContext, int)? separatorBuilder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(T.blockedMembers.tr),
      ),
      body: MeetupDoc(
        meetup: meetup,
        builder: (meetupDoc) => ListView.separated(
          padding: padding ?? const EdgeInsets.all(16),
          itemBuilder: (_, i) {
            final uid = meetupDoc.blockedUsers[i];
            return UserDoc(
              uid: uid,
              onLoading: const SizedBox.shrink(),
              builder: (user) {
                return Card(
                  child: UserTile(
                    user: user,
                    trailing: PopupMenuButton(
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: Code.unblock,
                          child: Text(T.unblock.tr),
                        ),
                      ],
                      onSelected: (v) async {
                        if (v == Code.unblock) {
                          await meetupDoc.unblockUser(
                            context: context,
                            otherUserUid: uid,
                            ask: true,
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            );
          },
          separatorBuilder: (_, __) =>
              separatorBuilder?.call(_, __) ??
              const SizedBox(
                height: 16,
              ),
          itemCount: meetupDoc.blockedUsers.length,
        ),
      ),
    );
  }
}
