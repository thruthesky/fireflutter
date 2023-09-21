import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// PostListScreen
///
/// Display a full screen dialog to show list of posts
class PostListScreen extends StatefulWidget {
  const PostListScreen({
    super.key,
    this.categoryId,
    this.title,
  });

  final String? categoryId;
  final String? title;

  @override
  State<PostListScreen> createState() => _PostListDialogState();
}

class _PostListDialogState extends State<PostListScreen> {
  // Category? category;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title ?? widget.categoryId ?? "@t - Post List"),
        actions: [
          if (widget.categoryId != null) PostListCategorySubscription(widget.categoryId!),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final post = await PostService.instance.showEditScreen(
                context,
                categoryId: widget.categoryId,
              );

              if (post != null) {
                if (mounted) {
                  Navigator.pop(context);
                  PostService.instance.showPostViewScreen(context: context, post: post);
                }
              }
            },
          ),
          PopupMenuButton(
            icon: const Icon(Icons.settings),
            itemBuilder: (context) {
              List<PopupMenuEntry<Object>> popupMenuItemList = [];
              popupMenuItemList.add(
                const PopupMenuItem(
                  value: "adjust_text_size",
                  child: Text("Adjust text size"),
                ),
              );
              if (UserService.instance.isAdmin) {
                popupMenuItemList.add(
                  const PopupMenuDivider(
                    height: 20,
                  ),
                );
                if (widget.categoryId != null) {
                  popupMenuItemList.add(
                    const PopupMenuItem(
                      value: "category_settings",
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Category Settings"),
                        ],
                      ),
                    ),
                  );
                }
                popupMenuItemList.add(
                  const PopupMenuItem(
                    value: "category_list",
                    child: Text('Category List'),
                  ),
                );
              }
              return popupMenuItemList;
            },
            onSelected: (value) {
              switch (value) {
                case "category_settings":
                  if (widget.categoryId != null) {
                    CategoryService.instance.showUpdateDialog(context, widget.categoryId!);
                  } else {
                    CategoryService.instance.showListDialog(
                      context,
                      onTapCategory: (category) =>
                          CategoryService.instance.showUpdateDialog(context, widget.categoryId!),
                    );
                  }
                  break;

                case "category_list":
                  CategoryService.instance.showListDialog(
                    context,
                    onTapCategory: (category) => CategoryService.instance.showUpdateDialog(context, category.id),
                  );
                  break;

                case "adjust_te":
                  // context.push('/adjust_text_size');
                  break;
              }
            },
          )
        ],
      ),
      body: const PostListView(),
    );
  }
}
