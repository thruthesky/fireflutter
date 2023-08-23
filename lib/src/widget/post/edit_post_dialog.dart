import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/model/post.dart';
import 'package:flutter/material.dart';

class EditPostDialog extends StatefulWidget {
  const EditPostDialog({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  State<EditPostDialog> createState() => _EditPostDialogState();
}

class _EditPostDialogState extends State<EditPostDialog> {
  TextEditingController title = TextEditingController();
  TextEditingController content = TextEditingController();
  // TODO file upload

  @override
  Widget build(BuildContext context) {
    title.text = widget.post.title;
    content.text = widget.post.content;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Post'), // TODO tr
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Category'),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0),
            child: TextFormField(
              controller: title,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Title',
              ),
            ),
          ),
          ListTile(
            leading: UserAvatar(
              uid: UserService.instance.uid,
            ),
            title: UserDisplayName(
              uid: UserService.instance.uid,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TimestampText(
                  timestamp: widget.post.createdAt,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
            child: TextFormField(
              controller: content,
              minLines: 2,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Content',
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                child: const Text('Update'),
                onPressed: () async {
                  if (title.text.isNotEmpty && content.text.isNotEmpty) {
                    PostService.instance
                        .editPost(
                      postId: widget.post.id,
                      title: title.text,
                      content: content.text,
                    )
                        .then((value) {
                      Navigator.pop(context);
                    });
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
