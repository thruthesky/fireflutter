import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/models/chat_room_model.dart';
import 'package:flutter/material.dart';

/// Display users who are not inside the room
///
/// TODO: Display only users who open their profile.
class InviteUserListView extends StatelessWidget {
  const InviteUserListView({
    super.key,
    required this.room,
    required this.searchText,
    this.exemptedUsers = const [],
    this.onInvite,
  });

  final ChatRoomModel room;
  final String searchText;
  final List<String> exemptedUsers;
  final Function(String invitedUserUid)? onInvite;

  @override
  Widget build(BuildContext context) {
    // ! Currently we can only search using exact display name
    final query = FirebaseFirestore.instance
        .collection('users')
        .where("displayName", isEqualTo: searchText)
        .where(FieldPath.documentId, whereNotIn: room.users.take(10));
    debugPrint("refreshed?");
    return FirestoreListView(
      query: query,
      itemBuilder: (context, snapshot) {
        final user = UserModel.fromDocumentSnapshot(snapshot);
        if (exemptedUsers.contains(user.uid)) {
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
              room.invite(user.uid);
              onInvite?.call(user.uid);
            },
          );
        }
      },
    );
  }
}
