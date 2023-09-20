import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/widget/admin/admin.post_list.screen.dart';
import 'package:flutter/material.dart';

class AdminService {
  static AdminService? _instance;
  static AdminService get instance => _instance ?? AdminService._();

  AdminService._();

  showDashboard({required BuildContext context}) {
    showGeneralDialog(
      context: context,
      pageBuilder: ($, $$, $$$) {
        return const AdminDashboardScreen();
      },
    );
  }

  showUserSearchDialog(BuildContext context, {Function(User)? onTap}) {
    final input = TextEditingController();
    showGeneralDialog(
      context: context,
      pageBuilder: ($, $$, $$$) {
        return StatefulBuilder(builder: (context, setState) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Choose User'),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: TextField(
                  controller: input,
                  decoration: InputDecoration(
                    label: const Text('Search'),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {});
                      },
                      icon: const Icon(Icons.send),
                    ),
                  ),
                ),
              ),
            ),
            body: AdminUserListView(
              displayName: input.text,
              onTap: onTap,
            ),
          );
        });
      },
    );
  }

  showPostListDialog(BuildContext context, {Function(Post)? onTap}) {
    showGeneralDialog(
      context: context,
      pageBuilder: ($, $$, $$$) {
        return StatefulBuilder(builder: (context, setState) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Choose Post'),
            ),
            body: PostListView(
              onTap: onTap,
            ),
          );
        });
      },
    );
  }

  showChatRoomListDialog(BuildContext context, {Function(Room)? onTap}) {
    final controller = ChatRoomListViewController();
    showGeneralDialog(
      context: context,
      pageBuilder: ($, $$, $$$) {
        return StatefulBuilder(builder: (context, setState) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Choose Chatroom'),
            ),
            body: ChatRoomListView(
              controller: controller,
              allChat: true,
              onTap: onTap,
            ),
          );
        });
      },
    );
  }

  // TODO show Chat Room Details
}
