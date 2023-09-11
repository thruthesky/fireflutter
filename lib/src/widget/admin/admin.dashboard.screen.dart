import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/widget/admin/admin.comment_list.screen.dart';
import 'package:fireflutter/src/widget/admin/admin.post_list.screen.dart';
import 'package:fireflutter/src/widget/admin/admin.user_list.screen.dart';
import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.close,
              color: Theme.of(context).colorScheme.onInverseSurface),
        ),
        title: Text(
          'Admin Dashboard',
          style:
              TextStyle(color: Theme.of(context).colorScheme.onInverseSurface),
        ),
      ),
      body: Column(
        children: [
          TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const AdminUserListScreen()),
                );
              },
              child: const Text('Users')),
          TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const AdminPostListScreen()),
                );
              },
              child: const Text('Post')),
          TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const AdminCommentListScreen()),
                );
              },
              child: const Text('Comment')),
          TextButton(onPressed: () {}, child: const Text('Photos')),
          TextButton(
              onPressed: () {
                // CategoryService.instance.showListDialog(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const AdminCategoryListScreen()),
                );
              },
              child: const Text('Category')),
          TextButton(onPressed: () {}, child: const Text('Report')),
        ],
      ),
    );
  }
}
