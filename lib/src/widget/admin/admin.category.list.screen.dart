import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// Admin chat room list
///
/// Note that, it may be an illegal operation to view chat messages of users.
///
class AdminCategoryListScreen extends StatelessWidget {
  const AdminCategoryListScreen({
    super.key,
    this.onTapCategory,
  });

  final Function(Category category)? onTapCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme.copyWith(color: Theme.of(context).colorScheme.onInverseSurface),
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        title: Text('Category List', style: TextStyle(color: Theme.of(context).colorScheme.onInverseSurface)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              CategoryService.instance.showCreateDialog(
                context,
                success: (category) {
                  Navigator.pop(context);
                  CategoryService.instance.showUpdateDialog(context, category.id);
                },
              );
            },
          ),
        ],
      ),
      body: CategoryListView(
        onTap: (category) {
          CategoryService.instance.showUpdateDialog(context, category.id);
        },
      ),
    );
  }
}
