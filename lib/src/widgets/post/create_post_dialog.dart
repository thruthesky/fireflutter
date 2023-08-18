import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/models/post.dart';
import 'package:flutter/material.dart';

class CreatePostDialog extends StatefulWidget {
  const CreatePostDialog({
    super.key,
    required this.success,
  });

  final void Function(Post post) success;

  @override
  State<CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<CreatePostDialog> {
  TextEditingController title = TextEditingController();
  TextEditingController content = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // String categoryId = 'discussion'; // TODO , still ongoing
    String categoryName = 'Discussion'; // TODO , still ongoing
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0),
            child: Text('Category: $categoryName'),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0),
            child: TextFormField(
              controller: title,
              decoration: const InputDecoration(
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
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              controller: content,
              decoration: const InputDecoration(
                labelText: 'Content',
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                child: const Text('Post'),
                onPressed: () {
                  // PostService
                  debugPrint('Posting it');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
