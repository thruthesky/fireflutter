import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easychat/easychat.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';

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
