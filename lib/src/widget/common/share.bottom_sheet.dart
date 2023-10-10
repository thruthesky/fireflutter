import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class ShareBottomSheet extends StatefulWidget {
  const ShareBottomSheet({
    super.key,
    this.actions = const [],
    this.text,
  });

  final List<Widget> actions;
  final String? text;

  @override
  State<ShareBottomSheet> createState() => _ShareBottomSheetState();
}

class _ShareBottomSheetState extends State<ShareBottomSheet> {
  final name = TextEditingController();
  final nameChanged = BehaviorSubject<String?>.seeded(null);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      margin: const EdgeInsets.symmetric(horizontal: sizeSm),
      child: Column(
        children: [
          Container(
            height: 4,
            width: 28,
            margin: const EdgeInsets.symmetric(vertical: sizeSm),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Theme.of(context).colorScheme.secondary.withAlpha(80),
            ),
          ),
          TextField(
            controller: name,
            decoration: InputDecoration(
              hintText: "Search user...",
              prefixIcon: const Icon(Icons.search),
              border: InputBorder.none,
              filled: true,
              fillColor: Theme.of(context).colorScheme.secondary.withAlpha(50),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 0,
                vertical: 0,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) => nameChanged.add(value),
            onSubmitted: (value) => nameChanged.add(value),
          ),
          const SizedBox(
            height: sizeMd,
          ),
          StreamBuilder<String?>(
            stream: nameChanged.stream
                .debounceTime(const Duration(milliseconds: 500))
                .distinct((a, b) => a == b),
            builder: (context, snapshot) {
              return Text(
                  name.text.isEmpty ? "Users I follow" : "Search result");
            },
          ),
          Expanded(
            child: StreamBuilder<String?>(
                stream: nameChanged.stream
                    .debounceTime(const Duration(milliseconds: 500))
                    .distinct((a, b) => a == b),
                builder: (context, snapshot) {
                  if (name.text.isNotEmpty) {
                    return FirestoreListView(
                      query: userCol.where("displayName", isEqualTo: name.text),
                      itemBuilder: (context, snapshot) {
                        final user = User.fromDocumentSnapshot(snapshot);
                        return itemTile(user);
                      },
                    );
                  }
                  return UserListView.builder(
                    uids: my.followings,
                    itemBuilder: (user) {
                      if (user == null) return const SizedBox();
                      return itemTile(user);
                    },
                  );
                }),
          ),
          Wrap(
            spacing: 16,
            children: widget.actions,
          ),
          const SafeArea(
              child: SizedBox(
            height: sizeMd,
          ))
        ],
      ),
    );
  }

  Widget itemTile(User user) {
    return ListTile(
      leading: UserAvatar(
        user: user,
        size: 32,
      ),
      title: Text(user.displayName),
      subtitle: Text(user.email),
      trailing: const Icon(Icons.check),
      onTap: () {
        // TODO other share chat function without showing chat room
        // Cannot proceed because dynamic link is not working within the app.
        // https://github.com/users/thruthesky/projects/9/views/29?pane=issue&itemId=40666571
        ChatService.instance.showChatRoom(
            context: context,
            user: user,
            setMessage: widget.text ?? 'Sharing this...');
      },
    );
  }
}
