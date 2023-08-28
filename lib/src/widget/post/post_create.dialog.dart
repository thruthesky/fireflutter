import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/model/post.dart';
import 'package:flutter/material.dart';

class PostCreateDialog extends StatefulWidget {
  const PostCreateDialog({
    super.key,
    required this.success,
    this.categoryId,
  });

  final void Function(Post post) success;
  final String? categoryId;

  @override
  State<PostCreateDialog> createState() => _PostCreateDialogState();
}

class _PostCreateDialogState extends State<PostCreateDialog> {
  TextEditingController title = TextEditingController();
  TextEditingController content = TextEditingController();

  late String categoryId = '';
  String categoryName = '';
  // TODO file upload

  @override
  void initState() {
    super.initState();
    categoryId = widget.categoryId ?? '';
    categoryName = widget.categoryId ?? '@t Post Create';
    if (widget.categoryId != null) {
      CategoryService.instance.get(widget.categoryId!).then((cat) {
        setState(() {
          categoryName = cat!.name;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: DropdownMenu<String>(
                  initialSelection: categoryId,
                  dropdownMenuEntries: [
                    const DropdownMenuEntry(
                      value: '',
                      label: 'Select Category',
                    ),
                    ...CategoryService.instance.categoriesOnCreate.entries.map((e) {
                      return DropdownMenuEntry(
                        value: e.key,
                        label: e.value,
                      );
                    }).toList(),
                  ],
                  onSelected: (value) {
                    setState(() {
                      categoryId = value ?? '';
                    });
                  }),
            ),
            TextField(
              controller: title,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Title',
              ),
            ),
            TextField(
              controller: content,
              minLines: 2,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Content',
              ),
            ),
            ElevatedButton(
              child: const Text('Post'),
              onPressed: () async {
                if (title.text.isNotEmpty && content.text.isNotEmpty) {
                  PostService.instance
                      .createPost(
                    categoryId: categoryId,
                    title: title.text,
                    content: content.text,
                  )
                      .then((post) {
                    Navigator.pop(context);
                    PostService.instance.showPostViewDialog(context, post);
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
