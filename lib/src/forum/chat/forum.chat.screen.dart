import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ForumChatViewScreen extends StatefulWidget {
  const ForumChatViewScreen(
      {super.key, required this.title, required this.category});

  final String category;
  final String title;

  @override
  State<ForumChatViewScreen> createState() => _ForumChatViewScreenState();
}

class _ForumChatViewScreenState extends State<ForumChatViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: PostListView(
        reverse: true,
        category: widget.category,
        itemBuilder: (post, index) {
          if (post.id == '-O-i6VIsZjpNuvNrCzan') {
            dog(post.previewUrl.toString());
          }
          return PostBubble(key: Key(post.id), post: post);
        },
      ),
      bottomNavigationBar: Padding(
        /// This is to display the Textfield above the keyboard
        /// viewInsets is a space that consumed by the keyboard
        /// and used as a padding of bottomNavigationBar
        padding: MediaQuery.of(context).viewInsets,
        child: ForumChatInput(category: widget.category),
      ),
    );
  }
}
