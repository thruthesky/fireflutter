import 'package:fireflutter/fireflutter.dart';
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: sizeSm),
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

  showChoosePostScreen(BuildContext context, {Function(Post)? onTap}) {
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

  showChooseChatRoomScreen(BuildContext context, {Function(Room)? onTap}) {
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

  showChatRoomDetails(BuildContext context, {required Room room}) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) {
        // return Full screen for Chat Details
        return AdminChatRoomDetailsScreen(room: room);
      },
    );
  }
}
