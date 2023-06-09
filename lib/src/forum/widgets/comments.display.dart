import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/src/model/comment.model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'likes.counter.dart';

class CommentsDisplay extends StatefulWidget {
  const CommentsDisplay({super.key, required this.parentId});
  final String parentId;
  @override
  State<CommentsDisplay> createState() => _CommentsDisplayState();
}

class _CommentsDisplayState extends State<CommentsDisplay> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseDatabase.instance.ref('comments/${widget.parentId}').onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasData && snapshot.data!.snapshot.exists) {
          final data = jsonDecode(jsonEncode(snapshot.data!.snapshot.value));
          final List<CommentModel> comments = data.entries
              .map<CommentModel>(
                (e) => CommentModel.fromJson(e.key, e.value),
              )
              .toList();
          return Column(
            children: comments.map(
              (comment) {
                return Column(
                  children: [
                    ListTile(
                      title: Text(comment.content),
                      subtitle: Text(
                        DateFormat.yMMMEd().format(
                          DateTime.fromMillisecondsSinceEpoch(comment.createdAt),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        LikesCounter(id: comment.id),
                        LikeButton(),
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.create_outlined),
                          label: const Text('Reply'),
                        ),
                      ],
                    ),
                    // For the Reply on comment
                    // Padding(
                    //   padding: EdgeInsets.only(left: 50),
                    //   child: CommentsDisplay(parentId: comment.id),
                    // ),
                  ],
                );
              },
            ).toList(),
          );
        }
        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        return Center(
          child: Text(
            'No comments',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        );
      },
    );
  }
}
