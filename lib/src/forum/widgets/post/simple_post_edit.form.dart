import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class SimplePostEditForm extends StatefulWidget {
  const SimplePostEditForm({super.key, this.category, this.post});
  final String? category;
  final PostModel? post;

  @override
  State<SimplePostEditForm> createState() => _SimplePostEditFormState();
}

class _SimplePostEditFormState extends State<SimplePostEditForm> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  PostModel? _post;
  PostModel get post => _post!;

  bool get isCreate => widget.post == null;

  double? progress;
  @override
  void initState() {
    super.initState();

    // if (post != null) {}
    if (widget.post != null) {
      _post = widget.post!;
    } else {
      _post = PostModel.fromCategory(widget.category!);
    }

    titleController.text = post.title;
    contentController.text = post.content;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Title'),
        TextField(
          controller: titleController,
        ),
        const Text('Description'),
        TextField(
          controller: contentController,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.camera_alt)),
            ElevatedButton(
              onPressed: () async {
                if (isCreate) {
                  await PostModel.create(
                    category: post.category,
                    title: titleController.text,
                    content: contentController.text,
                    urls: post.urls,
                  );
                } else {
                  await post.update(
                    title: titleController.text,
                    content: contentController.text,
                    urls: post.urls,
                  );
                }
                if (mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: Text(isCreate ? 'CREATE' : 'UPDATE'),
            )
          ],
        ),
        if (progress != null && progress?.isNaN == false)
          LinearProgressIndicator(
            value: progress,
          ),
        const SizedBox(
          height: 8,
        ),
        EditUploads(
          urls: post.urls,
          onDelete: (url) => setState(() => post.urls.remove(url)),
        ),
      ],
    );
  }
}
