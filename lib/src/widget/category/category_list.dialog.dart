import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// Full screen dialog to show list of categories
class CategoryListDialog extends StatelessWidget {
  const CategoryListDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              CategoryService.instance.showCreateDialog(
                context,
                success: (category) {
                  Navigator.pop(context);
                  CategoryService.instance.showUpdateDialog(context, category);
                },
              );
            },
          ),
        ],
      ),
      body: const CategoryListView(),
    );
  }
}
