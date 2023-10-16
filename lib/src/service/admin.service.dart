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

  /// Show user search dialog
  /// [field] is the field to search. It can be 'name', 'displayName', or 'email'
  /// [onTap] is the function to call when the user is tapped.
  /// [avatarBuilder] is the function to build avatar.
  /// [titleBuilder] is the function to build title.
  /// [subtitleBuilder] is the function to build subtitle.
  /// [trailingBuilder] is the function to build trailing.
  showUserSearchDialog(
    BuildContext context, {
    Function(User)? onTap,
    Widget Function(User?)? avatarBuilder,
    Widget Function(User?)? titleBuilder,
    Widget Function(User?)? subtitleBuilder,
    Widget Function(User?)? trailingBuilder,
    String field = 'displayName',
  }) {
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
              name: field == 'name' ? input.text : null,
              displayName: field == 'displayName' ? input.text : null,
              email: field == 'email' ? input.text : null,
              onTap: onTap,
              avatarBuilder: avatarBuilder,
              titleBuilder: titleBuilder,
              subtitleBuilder: subtitleBuilder,
              trailingBuilder: trailingBuilder,
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
