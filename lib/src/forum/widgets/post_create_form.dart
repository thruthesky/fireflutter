import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/service/forum.service.dart';
import 'package:flutter/material.dart';

class PostCreateForm extends StatefulWidget {
  const PostCreateForm({
    super.key,
    required this.category,
  });

  final String category;

  @override
  State<PostCreateForm> createState() => _PostCreateFormState();
}

class _PostCreateFormState extends State<PostCreateForm> {
  final title = TextEditingController();
  final content = TextEditingController();

  // int orderNo = 0;

  // @override
  // void initState() {
  //   super.initState();
  //   ForumService.instance.categoryRef(widget.category).orderByChild('orderNo').limitToLast(1).once().then((snapshot) {
  //     if (snapshot.value != null) {
  //       Map<String, dynamic> post = Map<String, dynamic>.from(snapshot.value as dynamic);
  //       orderNo = post['orderNo'] + 1;
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text('Post Create',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).colorScheme.primary)),
          SizedBox(height: 16),
          TextField(
            controller: title,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Title',
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: content,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Content',
            ),
            minLines: 5,
            maxLines: 10,
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              Spacer(),
              StreamBuilder<DatabaseEvent>(
                stream: ForumService.instance
                    .categoryRef(widget.category)
                    .orderByChild('orderNo')
                    .limitToFirst(1)
                    .onChildAdded,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  final post = PostModel.fromSnapshot(snapshot.data!.snapshot);

                  return TextButton(
                    onPressed: () {
                      ForumService.instance.categoryRef(widget.category).push().set({
                        'title': title.text,
                        'content': content.text,
                        'orderNo': post.orderNo - 1,
                        'createdAt': DateTime.now().millisecondsSinceEpoch,
                      });
                      Navigator.pop(context);
                    },
                    child: Text('Create'),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
