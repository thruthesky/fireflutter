import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class PostCreateScreen extends StatefulWidget {
  static const String routeName = '/PostCreate';
  const PostCreateScreen({super.key, required this.category});

  final String category;

  @override
  State<PostCreateScreen> createState() => _PostCreateScreenState();
}

class _PostCreateScreenState extends State<PostCreateScreen> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
      ),
      body: Column(
        children: [
          const Text("PostCreate"),
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Title',
            ),
          ),
          TextField(
            controller: contentController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Content',
            ),
          ),
          ElevatedButton(
              onPressed: () async {
                await PostModel.create(
                  title: titleController.text,
                  content: contentController.text,
                  category: widget.category,
                );

                if (mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Submit'))
        ],
      ),
    );
  }
}
