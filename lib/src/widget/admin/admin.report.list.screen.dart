import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/model/report/report.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminReportListScreen extends StatefulWidget {
  static const String routeName = '/AdminReportList';
  const AdminReportListScreen({super.key});

  @override
  State<AdminReportListScreen> createState() => _AdminReportListScreenState();
}

class _AdminReportListScreenState extends State<AdminReportListScreen> {
  String type = 'all';

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
        title: const Text(
          'Admin Report List',
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: SizedBox(
            height: 48,
            child: ListView(scrollDirection: Axis.horizontal, children: [
              for (final target in [tr.labelAll, tr.labelUser, tr.labelPost, tr.labelComment])
                InkWell(
                  onTap: () {
                    setState(() {
                      type = target;
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio(
                        value: target,
                        groupValue: type,
                        onChanged: (String? value) {
                          dog('value change $value');
                          if (value != null) {
                            setState(() {
                              type = value;
                            });
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: sizeSm),
                        child: Text(
                          toBeginningOfSentenceCase(target)!,
                        ),
                      ),
                    ],
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
          return Container(
            padding: const EdgeInsets.fromLTRB(sizeSm, 0, sizeSm, sizeSm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(toBeginningOfSentenceCase(report.type) ?? '', style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        if (report.type == 'user') {
                          UserService.instance.showPublicProfileScreen(
                            context: context,
                            uid: report.otherUid,
                          );
                        } else if (report.type == 'post') {
                          PostService.instance.showPostViewScreen(context: context, postId: report.postId);
                        } else if (report.type == 'comment') {
                          CommentService.instance.showCommentViewDialog(context: context, commentId: report.commentId);
                        }
                      },
                      icon: Row(
                        children: [
                          Text(tr.labelView),
                          const Icon(Icons.open_in_browser),
                        ],
                      ),
                    )
                  ],
                ),
                Text('Reported ${toBeginningOfSentenceCase(report.type)}',
                    style: Theme.of(context).textTheme.labelMedium),
                Text(report.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: sizeSm),
                Text(
                  'Reporters',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                ...report.reporters
                    .map((e) => Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, sizeXxs, sizeXs, 0),
                              child: UserAvatar(
                                showBlocked: true,
                                uid: e,
                                radius: 12.5,
                                size: 25,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  UserDisplayName(
                                    showBlocked: true,
                                    uid: e,
                                  ),
                                  report.data[e] != null ? Text(report.data[e]) : const SizedBox.shrink(),
                                ],
                              ),
                            ),
                          ],
                        ))
                    .toList(),
                const SizedBox(height: sizeSm),
                Row(
                  children: [
                    const Text('First reported at '),
                    Expanded(
                      child: DateTimeText(
                        style: Theme.of(context).textTheme.labelMedium,
                        dateTime: report.createdAt,
                        type: DateTimeTextType.short,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: sizeSm),
                Row(
                  children: [
                    if (report.type == 'user')
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => showDisableDialog(report),
                          child: const Text('Disable User'),
                        ),
                      ),
                    if (report.type == 'post')
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => showDeleteDialog(report),
                          child: const Text('Delete Post'),
                        ),
                      ),
                    if (report.type == 'comment')
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => showDeleteDialog(report),
                          child: Text(tr.deletePost),
                        ),
                      ),
                    const SizedBox(width: sizeSm),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => showResolveDialog(report),
                        child: Center(
                            child: Text(
                          tr.markAsResolve,
                          textAlign: TextAlign.center,
                        )),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: sizeSm),
                const Divider(),
              ],
            ),
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
              child: Text(tr.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                report.markAsResolved();
              },
              child: Text(tr.markAsResolve),
            ),
          ],
        );
      },
    );
  }
}
