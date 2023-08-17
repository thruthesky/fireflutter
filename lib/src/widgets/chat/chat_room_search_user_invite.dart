import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/models/room.dart';
import 'package:flutter/material.dart';

class SearchUserInvite extends StatefulWidget {
  const SearchUserInvite({
    super.key,
    required this.room,
  });

  final Room room;
  @override
  State<SearchUserInvite> createState() => _SearchUserInviteState();
}

class _SearchUserInviteState extends State<SearchUserInvite> {
  TextEditingController search = TextEditingController();
  List<String>? roomMembers;

  @override
  Widget build(BuildContext context) {
    roomMembers ??= widget.room.users;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextFormField(
            controller: search,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
                hintText: 'Enter user\'s display name',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() {});
                  },
                )),
            onFieldSubmitted: (value) async {
              if (value.isNotEmpty) {
                setState(() {});
              }
            },
          ),
        ),
        Expanded(
          child: UserListView(
            searchText: search.text,
            exemptedUsers: roomMembers!,
            onTap: (user) async {
              await widget.room.invite(user.uid);
              setState(() {
                roomMembers!.add(user.uid);
              });
            },
          ),
        ),
      ],
    );
  }
}
