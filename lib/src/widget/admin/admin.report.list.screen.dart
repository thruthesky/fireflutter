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
  style(context) => TextStyle(color: Theme.of(context).colorScheme.onInverseSurface);

  String? type;

  get query {
    Query q = reportCol;
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
        leading: IconButton(
          key: const Key('AdminReportListBackButton'),
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onInverseSurface),
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
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(report.type),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      if (report.type == 'user') {
                        UserService.instance.showPublicProfileScreen(context: context, uid: report.otherUid);
                      } else if (report.type == 'post') {
                        PostService.instance.showPostViewScreen(context: context, postId: report.postId);
                      } else if (report.type == 'comment') {
                        CommentService.instance.showCommentViewDialog(context: context, commentId: report.commentId);
                      }
                    },
                    icon: const Icon(Icons.open_in_browser),
                  )
                ],
              ),
              Text(report.title),
              const Text('Reporters'),
              ...report.reporters
                  .map((e) => Column(
                        children: [
                          UserDoc(
                            uid: e,
                            builder: (u) => Text(
                              u.name,
                            ),
                          ),
                          report.data[e] != null ? Text(report.data[e]) : const SizedBox.shrink(),
                        ],
                      ))
                  .toList(),
              const Divider(),
              Text(report.createdAt.toString()),
              if (report.type == 'user')
                ElevatedButton(
                  onPressed: () => showDisableDialog(report),
                  child: const Text('Disable User'),
                ),
              if (report.type == 'post')
                ElevatedButton(
                  onPressed: () => showDeleteDialog(report),
                  child: const Text('Delete Post'),
                ),
              if (report.type == 'comment')
                ElevatedButton(
                  onPressed: () => showDeleteDialog(report),
                  child: const Text('Delete Comment'),
                ),
              ElevatedButton(
                onPressed: () => showResolveDialog(report),
                child: const Text('Mark as Resolved'),
              ),
            ],
          );
        },
      ),
    );
  }

  showDisableDialog(Report report) async {
    // Github issue https://github.com/users/thruthesky/projects/9/views/29?pane=issue&itemId=40666380
    final user = await User.get(report.otherUid!);
    user!.disable();
    toast(title: 'Disable User', message: 'Disabled user.');
    report.markAsResolved();
  }

  showDeleteDialog(Report report) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Deleting ${report.type}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                report.deleteContent();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  /// The report will be marked as resolved without deleting or blocking content of the user.
  /// This can be used if the report is a false alarm.
  /// Admin can also verify and clarify the report first by chatting and/or investigating more.
  showResolveDialog(Report report) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Marking as resolved without deleting or blocking?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                report.markAsResolved();
              },
              child: const Text('Mark as Resolved'),
            ),
          ],
        );
      },
    );
  }
}
