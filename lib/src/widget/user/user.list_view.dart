import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// Display users who are not inside the room
///
/// [searchText] Use this to search in a list of users
/// [exemptedUsers] Array of uids who are exempted in search results
///
/// TODO: Display only users who open their profile.
class UserListView extends StatelessWidget with FirebaseHelper {
  const UserListView({
    super.key,
    this.searchText,
    this.exemptedUsers = const [],
    this.field = 'displayName',
    this.onTap,
    this.onLongPress,
    this.avatarBuilder,
    this.titleBuilder,
    this.subtitleBuilder,
    this.trailingBuilder,
  });

  final String? searchText;
  final List<String> exemptedUsers;
  final Function(User)? onTap;
  final Function(User)? onLongPress;
  final String field;
  final Widget Function(User?)? avatarBuilder;
  final Widget Function(User?)? titleBuilder;
  final Widget Function(User?)? subtitleBuilder;
  final Widget Function(User?)? trailingBuilder;

  @override
  Widget build(BuildContext context) {
    Query query = userSearchCol;
    if (searchText != null && searchText != '') {
      query = query.where(field, isEqualTo: searchText);
    }
    return FirestoreListView(
      query: query,
      itemBuilder: (context, snapshot) {
        final user = User.fromDocumentSnapshot(snapshot);
        if (exemptedUsers.contains(user.uid)) {
          return const SizedBox();
        } else {
          return ListTile(
            title: titleBuilder?.call(user) ?? Text(user.toMap()[field] ?? ''),
            subtitle: subtitleBuilder?.call(user) ?? Text(user.createdAtDateTime.toString()),
            leading: avatarBuilder?.call(user) ?? UserAvatar(user: user),
            trailing: trailingBuilder?.call(user) ?? const Icon(Icons.chevron_right),
            onTap: () async {
              onTap?.call(user);
            },
            onLongPress: () async {
              onLongPress?.call(user);
            },
          );
        }
      },
      loadingBuilder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
