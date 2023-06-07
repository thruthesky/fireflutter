import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_database/firebase_ui_database.dart';

class Forum extends StatelessWidget {
  const Forum(this.category, {super.key});

  final String category;
  @override
  Widget build(BuildContext context) {
    final query = FirebaseDatabase.instance.ref('posts').child(category);
    print('query: ${query.path}');
    return FirebaseDatabaseListView(
      query: query,
      itemBuilder: (context, snapshot) {
        Map<String, dynamic> post = Map<String, dynamic>.from(snapshot.value as dynamic);
        return ListTile(
          title: Text('title: ${post['title']}'),
          trailing: Icon(Icons.chevron_right),
          onTap: () {
            showGeneralDialog(
              context: context,
              pageBuilder: (context, _, __) => Scaffold(
                appBar: AppBar(title: Text('Post')),
                body: Column(
                  children: [
                    Text('title: ${post['title']}'),
                    Text('content: ${post['content']}'),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: Text('Reply'),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text('Like'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
