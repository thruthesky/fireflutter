import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class CategoryDialog extends StatefulWidget {
  const CategoryDialog({
    super.key,
    required this.categoryId,
  });

  final String categoryId;

  @override
  State<CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<CategoryDialog> {
  TextEditingController name = TextEditingController();
  TextEditingController description = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: CategoryService.instance.get(widget.categoryId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final Category category = snapshot.data!;

        name.text = category.name;
        description.text = category.description ?? '';

        return Scaffold(
          appBar: AppBar(
            title: Text('Category (${category.name})'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Text.rich(
                  TextSpan(
                    text: 'Category ID: ',
                    children: [
                      TextSpan(
                          text: category.id,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                ),
                TextFormField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextFormField(
                  controller: description,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        child: const Text('Update'),
                        onPressed: () {
                          Category.fromId(category.id).update(
                              name: name.text, description: description.text);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
