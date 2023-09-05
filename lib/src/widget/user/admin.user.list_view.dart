import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// Display users who are not inside the room
///
/// [displayName] is to search users by that display name. You may put search
/// box on the parent widget and when the box is submitted, pass the display
/// name to this widget to search users by display name.
///
///
///
class AdminUserListView extends StatelessWidget with FirebaseHelper {
  const AdminUserListView({
    super.key,
    this.onTap,
    this.avatarBuilder,
    this.titleBuilder,
    this.subtitleBuilder,
    this.trailingBuilder,
    this.displayName,
    this.isComplete,
    this.isVerified,
  });

  final Function(User)? onTap;
  final Widget Function(User?)? avatarBuilder;
  final Widget Function(User?)? titleBuilder;
  final Widget Function(User?)? subtitleBuilder;
  final Widget Function(User?)? trailingBuilder;

  final String? displayName;
  final bool? isComplete;
  final bool? isVerified;

  Query get query {
    final db = FirebaseFirestore.instance;

    Query query = db.collection(User.collectionName);

    if (displayName != null) {
      query = query.where('displayName', isEqualTo: displayName);
    }

    if (isComplete == true) {
      query = query.where('isComplete', isEqualTo: isComplete);
    }

    if (isVerified == true) {
      query = query.where('isVerified', isEqualTo: isVerified);
    }

    // query = query.where('uid', isEqualTo: UserService.instance.uid);
    // query = query.orderBy('createdAt', descending: true);
    return query;
  }

  @override
  Widget build(BuildContext context) {
    return FirestoreListView(
      query: query,
      itemBuilder: (context, snapshot) {
        // print(snapshot.reference.path);
        // print(snapshot.data());
        final user = User.fromDocumentSnapshot(snapshot);

        return ListTile(
          title: titleBuilder?.call(user) ?? Text(user.displayName),
          subtitle: subtitleBuilder?.call(user) ?? Text(user.createdAt.toString()),
          leading: avatarBuilder?.call(user) ?? UserAvatar(user: user),
          trailing: trailingBuilder?.call(user) ?? const Icon(Icons.chevron_right),
          onTap: () async {
            onTap?.call(user);
          },
        );
      },
      loadingBuilder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}