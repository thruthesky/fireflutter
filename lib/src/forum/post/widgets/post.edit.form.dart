import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PostEditForm extends StatefulWidget {
  const PostEditForm({super.key, this.category, this.post});
  final String? category;
  final Post? post;

  @override
  State<PostEditForm> createState() => _SimplePostEditFormState();
}

class _SimplePostEditFormState extends State<PostEditForm> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  Post? _post;
  Post get post => _post!;

  bool get isCreate => widget.post == null;
  bool get isUpdate => !isCreate;

  double? progress;
  @override
  void initState() {
    super.initState();

    // if (post != null) {}
    if (widget.post != null) {
      _post = widget.post!;
    } else {
      _post = Post.fromCategory(widget.category!);
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
                  await Post.create(
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
                if (context.mounted) {
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
          onDelete: (url) async {
            setState(() => post.urls.remove(url));
            if (isUpdate) {
              await post.update(
                title: titleController.text,
                content: contentController.text,
                urls: post.urls,
              );
            }
          },
        ),
      ],
    );
  }
}
