import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// Display users who are not inside the room
///
/// [searchText] Use this to search in a list of users
/// [exemptedUsers] Array of uids who are exempted in search results
///
class AdminUserListView extends StatelessWidget with FirebaseHelper {
  const AdminUserListView({
    super.key,
    this.searchText,
    this.field = 'displayName',
    this.onTap,
    this.avatarBuilder,
    this.titleBuilder,
    this.subtitleBuilder,
    this.trailingBuilder,
  });

  final String? searchText;
  final Function(User)? onTap;
  final String field;
  final Widget Function(User?)? avatarBuilder;
  final Widget Function(User?)? titleBuilder;
  final Widget Function(User?)? subtitleBuilder;
  final Widget Function(User?)? trailingBuilder;

  Query get query {
    final db = FirebaseFirestore.instance;

    Query query = db.collection(User.collectionName);

    if (searchText != null && searchText != '') {
      query = query.where(field, isEqualTo: searchText);
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
        print(snapshot.reference.path);
        print(snapshot.data());
        final user = User.fromDocumentSnapshot(snapshot);

        return ListTile(
          title: titleBuilder?.call(user) ?? Text(user.uid),
          subtitle: subtitleBuilder?.call(user) ?? Text(user.createdAtDateTime.toString()),
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
