import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/model/report/report.dart';
import 'package:flutter/material.dart';

class AdminReportListScreen extends StatefulWidget {
  static const String routeName = '/AdminReportList';
  const AdminReportListScreen({super.key});

  @override
  State<AdminReportListScreen> createState() => _AdminReportListScreenState();
}

class _AdminReportListScreenState extends State<AdminReportListScreen> {
  style(context) =>
      TextStyle(color: Theme.of(context).colorScheme.onInverseSurface);

  String? type;

  get query {
    Query q = Report.col;
    if (type == 'user') {
      q = q.where('type', isEqualTo: 'user');
    } else if (type == 'post') {
      q = q.where('type', isEqualTo: 'post');
    } else if (type == 'comment') {
      q = q.where('type', isEqualTo: 'comment');
    }

    q = q.orderBy('createdAt', descending: true);

    return q;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.onInverseSurface),
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        title: Text(
          'Admin Report List',
          style: style(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: SizedBox(
            height: 48,
            child: ListView(scrollDirection: Axis.horizontal, children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    type = null;
                  });
                },
                child: Text(
                  "All",
                  style: style(context),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    type = 'user';
                  });
                },
                child: Text(
                  "Users",
                  style: style(context),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    type = 'post';
                  });
                },
                child: Text(
                  "Posts",
                  style: style(context),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    type = 'comment';
                  });
                },
                child: Text(
                  "Comments",
                  style: style(context),
                ),
              ),
            ]),
          ),
        ),
      ),
      body: FirestoreListView(
        query: query,
        itemBuilder: (context, snapshot) {
          final report = Report.fromDocumentSnapshot(snapshot);

          return ListTile(
            title: Text(report.reason),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(report.type),
                Text(report.createdAt.toString()),
                if (report.type == 'user')
                  ElevatedButton(
                      onPressed: () {}, child: const Text('Block User')),
                if (report.type == 'post')
                  ElevatedButton(
                      onPressed: () {}, child: const Text('Delete Post')),
                if (report.type == 'comment')
                  ElevatedButton(
                      onPressed: () {}, child: const Text('Delete Comment'))
              ],
            ),
            onTap: () {
              if (report.type == 'user') {
                UserService.instance
                    .showPublicProfileScreen(context: context, uid: report.uid);
              } else if (report.type == 'post') {
                PostService.instance.showPostViewScreen(
                    context: context, postId: report.postId);
              } else if (report.type == 'comment') {
                CommentService.instance.showCommentViewDialog(
                    context: context, commentId: report.commentId);
              }
            },
          );
        },
      ),
    );
  }
}
