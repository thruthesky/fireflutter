import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/model/post.dart';
import 'package:flutter/material.dart';

class CreatePostDialog extends StatefulWidget {
  const CreatePostDialog({
    super.key,
    required this.success,
    required this.category,
  });

  final void Function(Post post) success;
  final Category category;

  @override
  State<CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<CreatePostDialog> {
  TextEditingController title = TextEditingController();
  TextEditingController content = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text('Category: ${widget.category.name}'), // TODO
            ),
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
                Text('${Timestamp.now().toDate()}'),
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
              // TODO allow submit only when title and content is not empty
              ElevatedButton(
                child: const Text('Post'),
                onPressed: () async {
                  PostService.instance
                      .createPost(
                    categoryId: widget.category.id,
                    title: title.text,
                    content: content.text,
                  )
                      .then((post) {
                    /// TODO go to the post
                    Navigator.pop(context);
                    PostService.instance.showPostDialog(context, post);
                    debugPrint("Go to ${post.id}");
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
