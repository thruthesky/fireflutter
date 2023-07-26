import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easychat/easychat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ChatRoomListViewController {
  late final ChatRoomListViewState state;

  ///
  showChatRoom({required BuildContext context, UserModel? user, ChatRoomModel? room}) {
    EasyChat.instance.showChatRoom(context: context, user: user, room: room);
  }
}

/// ChatRoomListView
///
/// It uses [FirestoreListView] to show the list of chat rooms which uses [ListView] internally.
/// And it supports some(not all) of the ListView properties.
///
/// Note that, the controller of ListView is named [scrollController] in this class.
class ChatRoomListView extends StatefulWidget {
  const ChatRoomListView({
    super.key,
    required this.controller,
    this.itemBuilder,
    this.pageSize = 10,
    this.scrollController,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.clipBehavior = Clip.hardEdge,
  });

  final ChatRoomListViewController controller;
  final int pageSize;
  final Widget Function(BuildContext, ChatRoomModel)? itemBuilder;
  final ScrollController? scrollController;
  final bool? primary;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;

  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final Clip clipBehavior;

  // final void Function(ChatRoomModel) onTap;

  @override
  State<ChatRoomListView> createState() => ChatRoomListViewState();
}

class ChatRoomListViewState extends State<ChatRoomListView> {
  @override
  void initState() {
    super.initState();
    widget.controller.state = this;
  }

  @override
  Widget build(BuildContext context) {
    if (EasyChat.instance.loggedIn == false) {
      return const Center(child: Text('Error - Please, login first to use Easychat'));
    }
    // Returning a List View of Chat Rooms
    return FirestoreListView(
      query: EasyChat.instance.chatCol
          .where('users', arrayContains: EasyChat.instance.uid)
          .orderBy('lastMessage.createdAt', descending: true),
      itemBuilder: (context, QueryDocumentSnapshot snapshot) {
        final room = ChatRoomModel.fromDocumentSnapshot(snapshot);
        if (widget.itemBuilder != null) {
          return widget.itemBuilder!(context, room);
        } else {
          return ChatRoomListTile(room: room);
        }
      },
      errorBuilder: (context, error, stackTrace) {
        log(error.toString(), stackTrace: stackTrace);
        return const Center(child: Text('Error loading chat rooms'));
      },
      pageSize: widget.pageSize,
      controller: widget.scrollController,
      primary: widget.primary,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      padding: widget.padding,
      dragStartBehavior: widget.dragStartBehavior,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      clipBehavior: widget.clipBehavior,
    );
  }
}

class ChatRoomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const ChatRoomAppBar({
    super.key,
    required this.room,
  });

  final ChatRoomModel room;

  @override
  createState() => ChatRoomAppBarState();

  @override
  final Size preferredSize = const Size.fromHeight(kToolbarHeight);
}

class ChatRoomAppBarState extends State<ChatRoomAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: ChatRoomAppBarTitle(room: widget.room),
      actions: [
        ChatRoomMenuButton(
          room: widget.room,
        ),
      ],
    );
  }
}

class ChatRoomMenuButton extends StatefulWidget {
  const ChatRoomMenuButton({
    super.key,
    required this.room,
  });

  final ChatRoomModel room;

  @override
  State<ChatRoomMenuButton> createState() => _ChatRoomMenuButtonState();
}

class _ChatRoomMenuButtonState extends State<ChatRoomMenuButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu),
      onPressed: () async {
        final otherUser =
            widget.room.group == true ? null : await EasyChat.instance.getOtherUserFromSingleChatRoom(widget.room);
        if (context.mounted) {
          showGeneralDialog(
            context: context,
            pageBuilder: (context, _, __) {
              return ChatRoomMenuScreen(
                room: widget.room,
                otherUser: otherUser,
              );
            },
          );
        }
      },
    );
  }
}

class ChatRoomMenuScreen extends StatefulWidget {
  const ChatRoomMenuScreen({
    super.key,
    required this.room,
    this.otherUser,
  });

  final ChatRoomModel room;
  final UserModel? otherUser;

  @override
  State<ChatRoomMenuScreen> createState() => _ChatRoomMenuScreenState();
}

class _ChatRoomMenuScreenState extends State<ChatRoomMenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Room'),
      ),
      body: ListView(
        children: [
          if (widget.room.group) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(widget.room.name),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(widget.otherUser!.displayName),
            ),
          ],
          if (!EasyChat.instance.isMaster(room: widget.room, uid: EasyChat.instance.uid)) ...[
            LeaveButton(
              room: widget.room,
            ),
          ],
          InviteUserButton(
            room: widget.room,
            onInvite: (invitedUserUid) {
              setState(() {});
            },
          ),
          ChatSettingsButton(room: widget.room),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 16.0, right: 16.0),
                child: Text('Members'),
              ),
              ChatRoomMembersListView(room: widget.room),
            ],
          ),
        ],
      ),
    );
  }
}

class ChatSettingsButton extends StatelessWidget {
  const ChatSettingsButton({
    super.key,
    required this.room,
  });

  final ChatRoomModel room;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: const Text('Settings'),
      onPressed: () {
        showGeneralDialog(
            context: context,
            pageBuilder: (context, _, __) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Settings'),
                ),
              );
            });
      },
    );
  }
}

class LeaveButton extends StatelessWidget {
  const LeaveButton({
    super.key,
    required this.room,
  });

  final ChatRoomModel room;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: const Text('Leave'),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Leaving Room"),
              content: const Text("Are you sure you want to leave the group chat?"),
              actions: [
                TextButton(
                  child: const Text("Leave"),
                  onPressed: () {
                    // TODO leave the room to prevent the error
                    EasyChat.instance.leaveRoom(
                        room: room,
                        callback: () {
                          // TODO or leave here
                        });
                    debugPrint("Leaving");
                  },
                ),
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            );
          },
        );
      },
    );
  }
}

class ChatMembersButton extends StatelessWidget {
  const ChatMembersButton({
    super.key,
    required this.room,
  });

  final ChatRoomModel room;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Members'),
      ),
      body: ChatRoomMembersListView(room: room),
    );
  }
}

class ChatRoomMembersListView extends StatefulWidget {
  const ChatRoomMembersListView({
    super.key,
    required this.room,
  });

  final ChatRoomModel room;

  @override
  State<ChatRoomMembersListView> createState() => _ChatRoomMembersListViewState();
}

class _ChatRoomMembersListViewState extends State<ChatRoomMembersListView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: widget.room.users.length,
      itemBuilder: (context, index) {
        return FutureBuilder(
          future: EasyChat.instance.getUser(widget.room.users[index]),
          builder: (context, userSnapshot) {
            return ListTile(
              title: Text(userSnapshot.data?.displayName ?? ''),
              // subtitle: Text(userSnapshot.data?.uid ?? ''),
              subtitle: Text(widget.room.master == userSnapshot.data?.uid
                  ? 'Master'
                  : widget.room.moderators.contains(userSnapshot.data?.uid)
                      ? 'Moderator'
                      : ''),
              leading: (userSnapshot.data?.photoUrl ?? '').isEmpty
                  ? null
                  : CircleAvatar(
                      backgroundImage: NetworkImage(userSnapshot.data!.photoUrl),
                    ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(userSnapshot.data?.displayName ?? userSnapshot.data?.uid ?? ''),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (EasyChat.instance.canRemove(room: widget.room, userUid: userSnapshot.data!.uid)) ...[
                            TextButton(
                              child: const Text('Remove from the Group'),
                              onPressed: () {
                                EasyChat.instance.removeUserFromRoom(
                                  room: widget.room,
                                  uid: userSnapshot.data!.uid,
                                  callback: () {
                                    setState(() {
                                      widget.room.users.remove(userSnapshot.data!.uid);
                                    });
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            ),
                          ],
                          if (EasyChat.instance.canSetUserAsModerator(room: widget.room, userUid: userSnapshot.data!.uid)) ...[
                            TextButton(
                              child: const Text("Add as a Moderator"),
                              onPressed: () {
                                EasyChat.instance.setUserAsModerator(
                                  room: widget.room,
                                  uid: userSnapshot.data!.uid,
                                  callback: () {
                                    setState(() {
                                      widget.room.moderators.add(userSnapshot.data!.uid);
                                    });
                                    Navigator.pop(context);
                                  },
                                );
                                debugPrint('Adding as Moderator');
                              },
                            )
                          ],
                          if (EasyChat.instance
                              .canRemoveUserAsModerator(room: widget.room, userUid: userSnapshot.data!.uid)) ...[
                            TextButton(
                              child: const Text("Remove as a Moderator"),
                              onPressed: () {
                                EasyChat.instance.removeUserAsModerator(
                                  room: widget.room,
                                  uid: userSnapshot.data!.uid,
                                  callback: () {
                                    setState(() {
                                      widget.room.moderators.remove(userSnapshot.data!.uid);
                                    });
                                    Navigator.pop(context);
                                  },
                                );
                                debugPrint('Removing as Moderator');
                              },
                            )
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class InviteUserButton extends StatelessWidget {
  const InviteUserButton({
    super.key,
    required this.room,
    this.onInvite,
  });

  final ChatRoomModel room;
  final Function(String invitedUserUid)? onInvite;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: const Text('Invite User'),
      onPressed: () {
        showGeneralDialog(
          context: context,
          pageBuilder: (context, _, __) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Invite Users'),
              ),
              body: InviteUserListView(
                // ! Is it better to relisten here? Will relistening, be a problem with number of reads?
                room: room,
                onInvite: (uid) {
                  onInvite?.call(uid);
                },
              ),
            );
          },
        );
      },
    );
  }
}

class InviteUserListView extends StatefulWidget {
  const InviteUserListView({
    super.key,
    required this.room,
    this.onInvite,
  });

  final ChatRoomModel room;
  final Function(String invitedUserUid)? onInvite;

  @override
  State<InviteUserListView> createState() => _InviteUserListViewState();
}

class _InviteUserListViewState extends State<InviteUserListView> {
  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance
        .collection(EasyChat.instance.usersCollection)
        .where(FieldPath.documentId, whereNotIn: widget.room.users.take(10)); // Error message says limit is 10
    return FirestoreListView(
      query: query,
      itemBuilder: (context, snapshot) {
        // TODO how to remove blinking
        final user = UserModel.fromDocumentSnapshot(snapshot);
        if (widget.room.users.contains(user.uid)) {
          return const SizedBox();
        } else {
          return ListTile(
            title: Text(user.displayName),
            subtitle: Text(user.uid),
            leading: user.photoUrl.isEmpty
                ? null
                : CircleAvatar(
                    backgroundImage: NetworkImage(user.photoUrl),
                  ),
            onTap: () {
              debugPrint("Adding user ${user.displayName}");
              EasyChat.instance.inviteUser(room: widget.room, user: user).then((value) {
                setState(() {
                  widget.room.users.add(user.uid);
                });
                widget.onInvite?.call(user.uid);
              });
            },
          );
        }
      },
    );
  }
}

class ChatRoomAppBarTitle extends StatelessWidget {
  const ChatRoomAppBarTitle({
    super.key,
    required this.room,
  });

  final ChatRoomModel room;
  @override
  Widget build(BuildContext context) {
    if (room.group) {
      return Row(
        children: [
          const SizedBox(width: 8),
          Text(room.name),
        ],
      );
    } else {
      return FutureBuilder(
        future: EasyChat.instance.getUser(room.otherUserUid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('Loading...');
          }
          if (snapshot.hasData == false) {
            return const Text('Error - no user');
          }
          final user = snapshot.data as UserModel;
          return Row(
            children: [
              user.photoUrl.isEmpty
                  ? const SizedBox()
                  : CircleAvatar(
                      backgroundImage: NetworkImage(user.photoUrl),
                    ),
              const SizedBox(width: 8),
              Text(user.displayName),
            ],
          );
        },
      );
    }
  }
}
