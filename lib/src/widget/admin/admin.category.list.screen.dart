import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// Full screen dialog to show list of categories
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
        iconTheme: Theme.of(context)
            .iconTheme
            .copyWith(color: Theme.of(context).colorScheme.onInverseSurface),
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        title: Text('Admin Comment List',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onInverseSurface)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              CategoryService.instance.showCreateDialog(
                context,
                success: (category) {
                  Navigator.pop(context);
                  CategoryService.instance
                      .showUpdateDialog(context, category.id);
                },
              );
            },
          ),
        ],
      ),
      body: CategoryListView(
        onTap: (category) {
          if (onTapCategory != null) {
            onTapCategory?.call(category);
          } else {
            PostService.instance.showPostListDialog(context, category.id);
          }
        },
      ),
    );
  }
}
