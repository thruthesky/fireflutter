import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/forum/widgets/post_view.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:intl/intl.dart';

class ForumController {
  late final _ForumState state;
}

class Forum extends StatefulWidget {
  const Forum({super.key, required this.category, required this.controller});

  final String category;
  final ForumController controller;

  @override
  State<Forum> createState() => _ForumState();
}

class _ForumState extends State<Forum> {
  @override
  void initState() {
    super.initState();
    widget.controller.state = this;
  }

  @override
  Widget build(BuildContext context) {
    final query = FirebaseDatabase.instance.ref('posts').child(widget.category).orderByChild('orderNo');

    return FirebaseDatabaseListView(
      query: query,
      itemBuilder: (context, snapshot) {
        final post = PostModel.fromSnapshot(snapshot);
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: InkWell(
            key: ValueKey('post-list-' + post.id),
            child: Container(
              width: double.infinity,
              color: Theme.of(context).colorScheme.primaryContainer,
              padding: EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(
                    post.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    DateFormat.yMMMEd().format(DateTime.fromMillisecondsSinceEpoch(post.createdAt)).toString(),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    post.content,
                    style: Theme.of(context).textTheme.bodyLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            onTap: () {
              showGeneralDialog(
                context: context,
                pageBuilder: (context, _, __) => Scaffold(
                  appBar: AppBar(title: Text('Post')),
                  body: PostViewScreen(
                    post: post,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  showPostCreateDialog(
    BuildContext context, {
    required String category,
  }) async {
    await showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) => Scaffold(
        appBar: AppBar(title: Text('Post Create')),
        body: PostCreateForm(
          category: category,
        ),
      ),
    );
  }
}
