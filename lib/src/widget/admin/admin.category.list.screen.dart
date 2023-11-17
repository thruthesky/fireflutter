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
        leading: IconButton(
          key: const Key('AdminCategoryListBackButton'),
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(tr.titleCategoryList),
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
