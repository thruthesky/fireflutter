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
        title: Text(categoryName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            InputDecorator(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                    isDense: false,
                    padding: const EdgeInsets.only(left: 12, top: 4, right: 4, bottom: 4),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem(
                        value: '',
                        child: Text('Select Category'),
                      ),
                      ...CategoryService.instance.categoriesOnCreate.entries.map((e) {
                        return DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value),
                        );
                      }).toList(),
                    ],
                    value: categoryId,
                    onChanged: (value) {
                      setState(() {
                        categoryId = value ?? '';
                      });
                    }),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: title,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: tr.form.title,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: content,
              minLines: 5,
              maxLines: 8,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: tr.form.content,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                IconButton(
                  onPressed: () async {
                    final url = await StorageService.instance.upload(context: context);
                  },
                  icon: const Icon(
                    Icons.camera_alt,
                    size: 36,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  child: Text(tr.form.postCreate),
                  onPressed: () async {
                    if (title.text.isEmpty) {
                      return warningSnackbar(context, tr.form.titleRequired);
                    }
                    if (content.text.isEmpty) {
                      return warningSnackbar(context, tr.form.contentRequired);
                    }
                    final post = await Post.create(categoryId: categoryId, title: title.text, content: content.text);
                    if (mounted) {
                      Navigator.pop(context);
                      PostService.instance.showPostViewDialog(context, post);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
