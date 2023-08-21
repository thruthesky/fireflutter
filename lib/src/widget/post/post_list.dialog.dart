import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// PostListDialog
///
/// Display a full screen dialog to show list of posts
class PostListDialog extends StatefulWidget {
  const PostListDialog({
    super.key,
    required this.categoryId,
  });

  final String categoryId;

  @override
  State<PostListDialog> createState() => _PostListDialogState();
}

class _PostListDialogState extends State<PostListDialog> {
  Category? category;

  @override
  void initState() {
    super.initState();
    CategoryService.instance.get(widget.categoryId).then((value) {
      setState(() {
        category = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(category?.name ?? ''),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              PostService.instance.showCreateDialog(
                context,
                category: category!,
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
                const PopupMenuItem(
                  value: "adjust_text_size",
                  child: Text("Adjust text size"),
                ),
                if (UserService.instance.isAdmin) ...[
                  const PopupMenuItem(
                    value: "category_settings",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(),
                        Text("Category Settings"),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: "category_list",
                    child: Text('Category List'),
                  ),
                ]
              ];
            },
            onSelected: (value) {
              switch (value) {
                case "category_settings":
                  if (category != null) CategoryService.instance.showUpdateDialog(context, category!);
                  break;

                case "category_list":
                  CategoryService.instance.showListDialog(context);
                  break;

                case "adjust_te":
                  // context.push('/adjust_text_size');
                  break;
              }
            },
          )
        ],
      ),
      body: PostListView(
        category: category,
      ),
    );
  }
}
