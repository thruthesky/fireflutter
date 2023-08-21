import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// This will display a full screen dialog with posts under a category
class ForumDialog extends StatefulWidget {
  const ForumDialog({
    super.key,
    this.user,
    required this.category,
  });
  final User? user;
  final Category category;

  @override
  State<ForumDialog> createState() => _ForumDialogState();
}

class _ForumDialogState extends State<ForumDialog> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("${widget.category.name} Posts"), // TODO category
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              PostService.instance.showCreateDialog(
                context,
                category: widget.category,
                success: (val) {
                  Navigator.pop(context);
                },
              );
            },
          ),
          PopupMenuButton(
            icon: const Icon(Icons.settings),
            itemBuilder: (context) {
              return [
                // TODO is this official way to check if Admin?
                // if (UserService.instance.isAdmin)
                const PopupMenuItem(
                  value: "category",
                  child: Text("Category Settings"),
                ),
                const PopupMenuItem(
                  value: "adjust_text_size",
                  child: Text("Adjust text size"),
                ),
              ];
            },
            onSelected: (value) {
              switch (value) {
                case "category":
                  // CategoryService.instance.showCategoryDialog(context, 'discussion')
                  break;
                case "adjust_te": // TODO options
                  // context.push('/adjust_text_size');
                  break;
              }
            },
          )
        ],
      ),
      body: PostListView(
        category: widget.category,
      ),
    );
  }
}
