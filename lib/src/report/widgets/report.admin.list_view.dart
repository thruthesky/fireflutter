import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class ReportAdminListView extends StatelessWidget {
  const ReportAdminListView({super.key});

  @override
  Widget build(BuildContext context) {
    print("ReportAdminListView build: ${Ref.reports.path}");
    return FirebaseDatabaseListView(
      query: Ref.reports,
      errorBuilder: (context, error, stackTrace) {
        dog("Error: $error");
        return Center(
          child: Text('Error: $error'),
        );
      },
      itemBuilder: (context, snapshot) {
        final ReportModel report =
            ReportModel.fromValue(snapshot.value, snapshot.key!);

        if (report.isPost) {
          return FutureBuilder<PostModel?>(
            future: PostModel.get(
              category: report.category!,
              id: report.postId!,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListTile(
                  leading: const Avatar(photoUrl: anonymousUrl),
                  title: Container(
                    height: 16,
                    width: 140,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      Container(
                        height: 16,
                        width: 140,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                );
              }
              final post = snapshot.data!;
              return ListTile(
                leading: UserAvatar(uid: post.uid),
                title: Text(report.reason),
                subtitle: Row(
                  children: [
                    const Text('[POST] '),
                    UserDoc.field(
                      uid: post.uid,
                      field: 'displayName',
                      builder: (name) => Text(name ?? ''),
                    ),
                    Text(' ${report.createdAt.toShortDate}'),
                  ],
                ),
              );
            },
          );
        } else if (report.isComment) {
          return FutureBuilder<CommentModel?>(
            future: CommentModel.get(
              postId: report.postId!,
              commentId: report.commentId!,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListTile(
                  leading: const Avatar(photoUrl: anonymousUrl),
                  title: Container(
                    height: 16,
                    width: 140,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      Container(
                        height: 16,
                        width: 140,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                );
              }
              final comment = snapshot.data!;
              return ListTile(
                leading: UserAvatar(uid: comment.uid),
                title: Text(report.reason),
                subtitle: Row(
                  children: [
                    const Text('[COMMNET] '),
                    UserDoc.field(
                      uid: comment.uid,
                      field: 'displayName',
                      builder: (name) => Text(name ?? ''),
                    ),
                    Text(' ${report.createdAt.toShortDate}'),
                  ],
                ),
              );
            },
          );
        } else if (report.isChatRoom) {
          return ListTile(
            title: Text(report.reason),
            subtitle: Row(
              children: [
                const Text('[CHAT] '),
                Value.once(
                    path: Path.chatRoomName(report.chatRoomId),
                    builder: (v) {
                      return Text(v);
                    }),
                Text(' ${report.createdAt.toShortDate}'),
              ],
            ),
          );
        } else {
          return ListTile(
            leading: UserAvatar(uid: report.otherUserUid!),
            title: Text(report.reason),
            subtitle: Row(
              children: [
                const Text('[USER] '),
                UserDisplayName(uid: report.otherUserUid!),
                Text(' ${report.createdAt.toShortDate}'),
              ],
            ),
          );
        }
      },
    );
  }
}
