import 'package:fireflutter/fireflutter.dart';

import 'package:flutter/material.dart';

class MeetupMembersListScreen extends StatelessWidget {
  const MeetupMembersListScreen({
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
        title: Text(T.members.tr),
      ),
      body: MeetupDoc(
        meetup: meetup,
        builder: (meetupDoc) => ListView.separated(
          padding: padding ?? const EdgeInsets.all(16),
          itemBuilder: (_, i) {
            final uid = meetupDoc.users[i];
            return UserDoc(
              uid: uid,
              onLoading: const SizedBox.shrink(),
              builder: (user) {
                return Card(
                  child: UserTile(
                    user: user,
                    trailing: (meetup.isMaster && user.uid != meetup.uid)
                        ? PopupMenuButton(
                            itemBuilder: (_) => [
                              PopupMenuItem(
                                value: Code.block,
                                child: Text(T.block.tr),
                              ),
                            ],
                            onSelected: (v) async {
                              if (v == Code.block) {
                                await meetupDoc.blockUser(
                                  context: context,
                                  otherUserUid: uid,
                                  ask: true,
                                );
                              }
                            },
                          )
                        : null,
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
          itemCount: meetupDoc.users.length,
        ),
      ),
    );
  }
}
