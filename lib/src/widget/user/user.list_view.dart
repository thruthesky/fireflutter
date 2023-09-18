import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// Display users who are not inside the room
///
/// [searchText] Use this to search in a list of users
/// [exemptedUsers] Array of uids who are exempted in search results
///
/// [itemBuilder] The builder when we want fully customized view per user.
///
class UserListView extends StatelessWidget {
  const UserListView({
    super.key,
    this.searchText,
    this.filter = const {},
    this.exemptedUsers = const [],
    this.field = 'displayName',
    this.onTap,
    this.onLongPress,
    this.avatarBuilder,
    this.titleBuilder,
    this.subtitleBuilder,
    this.trailingBuilder,
    this.itemBuilder,
    this.pageSize = 10,
    this.scrollDirection = Axis.vertical,
  });

  final String? searchText;
  final Map<String, dynamic> filter;
  final List<String> exemptedUsers;
  final Function(User)? onTap;
  final Function(User)? onLongPress;
  final String field;
  final Widget Function(User)? avatarBuilder;
  final Widget Function(User)? titleBuilder;
  final Widget Function(User)? subtitleBuilder;
  final Widget Function(User)? trailingBuilder;
  final Widget Function(User, int)? itemBuilder;

  final Axis scrollDirection;

  final int pageSize;

  bool get hasSearchText => searchText != null && searchText != '';

  @override
  Widget build(BuildContext context) {
    Query query = userSearchCol;
    if (hasSearchText) {
      query = query.where(field, isEqualTo: searchText);
    }
    for (String filterKey in filter.keys) {
      if (filter[filterKey] is String) {
        query = query.where(filterKey, isEqualTo: filter[filterKey]);
      }
      if (filter[filterKey] is List<dynamic>) {
        debugPrint("---> $filterKey, whereIn: ${filter[filterKey]}");
        query = query.where(filterKey, arrayContainsAny: filter[filterKey]);
      }
    }
    return FirestoreQueryBuilder(
      pageSize: pageSize,
      query: query,
      builder: (context, snapshot, _) {
        if (snapshot.isFetching) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Something went wrong! ${snapshot.error}');
        }

        return ListView.builder(
            scrollDirection: scrollDirection,
            itemCount: snapshot.docs.length,
            itemBuilder: (context, index) {
              // if we reached the end of the currently obtained items, we try to
              // obtain more items
              if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
                // Tell FirestoreQueryBuilder to try to obtain more items.
                // It is safe to call this function from within the build method.
                snapshot.fetchMore();
              }

              final user = User.fromDocumentSnapshot(snapshot.docs[index]);
              if (exemptedUsers.contains(user.uid)) return const SizedBox();
              if (itemBuilder != null) return itemBuilder!.call(user, index);
              return ListTile(
                title: titleBuilder?.call(user) ?? Text(user.toMap()[field] ?? ''),
                subtitle: subtitleBuilder?.call(user) ?? Text(user.createdAt.toString()),
                leading: avatarBuilder?.call(user) ?? UserAvatar(user: user),
                trailing: trailingBuilder?.call(user) ?? const Icon(Icons.chevron_right),
                onTap: () async {
                  onTap?.call(user);
                },
                onLongPress: () async {
                  onLongPress?.call(user);
                },
              );
            });
      },
    );
  }

  /// Use this builder when you already got a list of uids.
  static Widget builder({
    required List<String> uids,
    Widget Function(User? user)? itemBuilder,
    Widget Function()? loadingBuilder,
  }) {
    return ListView.builder(
      itemCount: uids.length,
      itemBuilder: (context, index) {
        return UserDoc(
          uid: uids[index],
          onLoading: loadingBuilder?.call() ??
              const ListTile(
                leading: CircularProgressIndicator(),
                title: Text('Loading...'),
              ),
          builder: (user) {
            return itemBuilder?.call(user) ??
                ListTile(
                  leading: UserAvatar(user: user),
                  title: Text(user.name),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    UserService.instance.showPublicProfileScreen(context: context, user: user);
                  },
                );
          },
        );
      },
    );
  }
}
