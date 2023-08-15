import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/models/chat_room_model.dart';
import 'package:flutter/material.dart';

/// Display users who are not inside the room
///
/// TODO: Don't display users who are not in the room.
/// TODO: Add search
/// TODO: Display only users who open their profile.
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
    final query = FirebaseFirestore.instance.collection('users').where(
        FieldPath.documentId,
        whereNotIn:
            widget.room.users.take(10)); // Error message says limit is 10
    return FirestoreListView(
      query: query,
      itemBuilder: (context, snapshot) {
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
            onTap: () async {
              widget.room.invite(user.uid);
              widget.onInvite?.call(user.uid);
            },
          );
        }
      },
    );
  }
}
