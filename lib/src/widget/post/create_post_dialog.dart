import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/model/post.dart';
import 'package:flutter/material.dart';

class CreatePostDialog extends StatefulWidget {
  const CreatePostDialog({
    super.key,
    required this.success,
    this.categoryId,
  });

  final void Function(Post post) success;
  final String? categoryId;

  @override
  State<CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<CreatePostDialog> {
  TextEditingController title = TextEditingController();
  TextEditingController content = TextEditingController();

  String categoryName = '';
  // TODO file upload

  @override
  void initState() {
    super.initState();
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
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text('Category: $categoryName'), // TODO
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
              ElevatedButton(
                child: const Text('Post'),
                onPressed: () async {
                  if (title.text.isNotEmpty && content.text.isNotEmpty) {
                    PostService.instance
                        .createPost(
                      categoryId: widget.categoryId!,
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
        ],
      ),
    );
  }
}
