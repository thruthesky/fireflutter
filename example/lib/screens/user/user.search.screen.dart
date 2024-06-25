import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class UserSearchScreen extends StatefulWidget {
  static const String routeName = '/user_search';
  const UserSearchScreen({
    super.key,
    this.title,
    this.onUserTap,
    this.hideUids = const [],
    this.trailing,
  });

  final String? title;
  final Function(User user)? onUserTap;
  final List<String> hideUids;
  final Widget? trailing;

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final searchController = TextEditingController();
  final change = PublishSubject<String>();

  get _query => FirebaseDatabase.instance
      .ref('users')
      .orderByChild(Field.displayName)
      // "A" will prevent numbers to display in the search
      // results if searchController.text.isEmpty
      .startAt(searchController.text.isEmpty ? "A" : searchController.text)
      .endAt("${searchController.text}쭿");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title ?? "Find Friends",
        ),
        toolbarHeight: 70,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search User",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: () => change.add(searchController.text),
                  icon: const Icon(
                    Icons.send,
                  ),
                ),
              ),
              onChanged: (v) => change.add(searchController.text),
              onSubmitted: (v) => change.add(searchController.text),
            ),
          ),
        ),
      ),
      body: StreamBuilder<Object>(
        stream: change.distinct((p, c) => p == c).debounceTime(
              const Duration(milliseconds: 500),
            ),
        builder: (context, snapshot) {
          return FirebaseDatabaseListView(
            query: _query,
            itemBuilder: (context, dataSnapshot) {
              User? user = User.fromSnapshot(dataSnapshot);
              if (widget.hideUids.contains(user.uid)) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: ListTile(
                  leading: UserAvatar(uid: user.uid),
                  title: Text(
                    user.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    user.stateMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing:
                      widget.trailing ?? const Icon(Icons.open_in_browser),
                  onTap: () async {
                    // widget.onUserTap?.call(user) ??
                    // show user profile
                    widget.onUserTap?.call(user) ??
                        UserService.instance.showPublicProfileScreen(
                          context: context,
                          user: user,
                        );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
