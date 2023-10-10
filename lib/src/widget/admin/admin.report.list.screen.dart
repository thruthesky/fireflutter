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
          return ListTile(
            title: Text(report.reason),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(report.type),
                Text(report.createdAt.toString()),
                if (report.resolved) ...[
                  const Text('Resolved'),
                  Text('Admin Notes: ${report.adminNotes}')
                ] else ...[
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
              ],
            ),
            onTap: () {
              if (report.type == 'user') {
                UserService.instance.showPublicProfileScreen(context: context, uid: report.otherUid);
              } else if (report.type == 'post') {
                PostService.instance.showPostViewScreen(context: context, postId: report.postId);
              } else if (report.type == 'comment') {
                CommentService.instance.showCommentViewDialog(context: context, commentId: report.commentId);
              }
            },
          );
        },
      ),
    );
  }

  showDisableDialog(Report report) {
    // TODO disable user
    // Github issue https://github.com/users/thruthesky/projects/9/views/29?pane=issue&itemId=40666380
    toast(title: 'Ongoing', message: '@todo disable user');
  }

  showDeleteDialog(Report report) {
    showDialog(
      context: context,
      builder: (context) {
        final reasonController = TextEditingController();
        reasonController.text = 'This ${report.type} was deleted due to violation.';
        final adminNotesController = TextEditingController();
        return AlertDialog(
          title: Text('Deleting ${report.type}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: reasonController,
                minLines: 2,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Reason (will show on app)',
                  hintText: 'This may appear on the ${report.type}.',
                ),
              ),
              TextField(
                controller: adminNotesController,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Admin Notes (for admins only)',
                  hintText: 'Please write notes for documentation...',
                ),
              ),
            ],
          ),
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
                report.deleteContent(reasonController.text, adminNotesController.text);
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
        final reasonController = TextEditingController();
        reasonController.text = 'This ${report.type} will not be deleted as reviewed by admin.';
        final adminNotesController = TextEditingController();
        return AlertDialog(
          title: const Text('Marking as Resolved'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: reasonController,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Reason (will show on app)',
                  hintText: 'This will be read by the reporter.',
                ),
              ),
              TextField(
                controller: adminNotesController,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Admin Notes (for admins only)',
                  hintText: 'Please write notes for documentation...',
                ),
              ),
            ],
          ),
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
                report.markAsResove();
              },
              child: const Text('Mark as Resolved'),
            ),
          ],
        );
      },
    );
  }
}
