import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class AdminService {
  static AdminService? _instance;
  static AdminService get instance => _instance ?? AdminService._();

  AdminService._();

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
}
