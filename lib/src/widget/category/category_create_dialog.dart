import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class CategoryCreateDialog extends StatefulWidget {
  const CategoryCreateDialog({
    super.key,
    required this.success,
    this.cancel,
  });

  final void Function(Category category) success;
  final void Function()? cancel;

  @override
  State<CategoryCreateDialog> createState() => _CategoryCreateDialogState();
}

class _CategoryCreateDialogState extends State<CategoryCreateDialog> {
  final name = TextEditingController();
  final categoryId = TextEditingController();
  bool isOpen = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Category'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: categoryId,
            decoration: const InputDecoration(
              labelText: 'Category ID (Permanent)',
            ),
          ),
          TextField(
            controller: name,
            decoration: const InputDecoration(
              labelText: 'Category Name',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.cancel != null ? widget.cancel!() : Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            await Category.create(
              categoryId: categoryId.text,
              name: name.text,
            );
            widget.success(await Category.get(categoryId.text));
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
