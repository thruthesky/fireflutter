import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class CategoryEditScreen extends StatefulWidget {
  const CategoryEditScreen({
    super.key,
    required this.categoryId,
  });

  final String categoryId;

  @override
  State<CategoryEditScreen> createState() => _CategoryEditScreenState();
}

class _CategoryEditScreenState extends State<CategoryEditScreen> {
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
            padding: const EdgeInsets.all(sizeSm),
            child: ListView(
              children: [
                Text.rich(
                  TextSpan(
                    text: '${tr.categoryId}: ',
                    children: [
                      TextSpan(
                          text: category.id,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: sizeSm),
                  child: TextFormField(
                    controller: name,
                    decoration: InputDecoration(labelText: tr.name),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: sizeSm),
                  child: TextFormField(
                    controller: description,
                    minLines: 3,
                    maxLines: 6,
                    decoration: InputDecoration(labelText: tr.description),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(sizeMd),
                      child: ElevatedButton(
                        child: Text(tr.update),
                        onPressed: () async {
                          await Category.fromId(category.id).update(name: name.text, description: description.text);
                          toast(title: tr.categoryUpdated, message: tr.categoryUpdatedMessage);
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
