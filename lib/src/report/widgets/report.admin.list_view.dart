import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Report list for admin
///
/// 1. all, unviewed, rejected, accepted, blocked list.
class ReportAdminListView extends StatelessWidget {
  const ReportAdminListView({super.key});

  @override
  Widget build(BuildContext context) {
    print("ReportAdminListView build: ${Report.reportsRef.path}");
    return FirebaseDatabaseListView(
      query: Report.reportsRef,
      errorBuilder: (context, error, stackTrace) {
        dog("Error: $error");
        return Center(
          child: Text('Error: $error'),
        );
      },
      itemBuilder: (context, snapshot) {
        final Report report = Report.fromValue(snapshot.value, snapshot.key!);

        if (report.isPost) {
          return FutureBuilder<Post?>(
            future: Post.get(
              category: report.category!,
              id: report.postId!,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator.adaptive();
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
                onTap: () => onTap(context, post.uid),
              );
            },
          );
        } else if (report.isComment) {
          return FutureBuilder<Comment?>(
            future: Comment.get(
              postId: report.postId!,
              commentId: report.commentId!,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator.adaptive();
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
                onTap: () => onTap(context, comment.uid),
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
                    // path: ChatRoom.chatRoomName(report.chatRoomId),
                    ref: ChatRoom.nameRef(report.chatRoomId!),
                    builder: (v) {
                      return Text(v ?? '');
                    }),
                Text(' ${report.createdAt.toShortDate}'),
              ],
            ),
            onTap: () => toast(
                context: context,
                message:
                    'Chat report management is not implemented yet. Admin should check the chat room and decide to destroy the chat room.'),
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
            onTap: () => onTap(context, report.otherUserUid!),
          );
        }
      },
    );
  }

  onTap(
    BuildContext context,
    String uid, {
    UserModel? user,
    Post? post,
    Comment? comment,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Management'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            UserAvatar(uid: uid),
            UserDisplayName(uid: uid),
            const SizedBox(height: 16),
            Wrap(
              children: [
                ElevatedButton(
                  onPressed: () {
                    UserService.instance
                        .showPublicProfileScreen(context: context, uid: uid);
                  },
                  child: const Text('View Profile'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Reject'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Accept'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Disable'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
