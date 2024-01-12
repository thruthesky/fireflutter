import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class PostUpdateScreen extends StatefulWidget {
  static const String routeName = '/PostCreate';
  const PostUpdateScreen({super.key, required this.post});

  final PostModel post;

  @override
  State<PostUpdateScreen> createState() => _PostUpdateScreenState();
}

class _PostUpdateScreenState extends State<PostUpdateScreen> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  @override
  void initState() {
    super.initState();

    titleController.text = widget.post.title;
    contentController.text = widget.post.content;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('글 수정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Title',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Content',
              ),
              minLines: 8,
              maxLines: 10,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: () async {
                  await widget.post.update(
                    title: titleController.text,
                    content: contentController.text,
                  );
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('UPDATE'))
          ],
        ),
      ),
    );
  }
}
