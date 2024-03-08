import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// Report list title for admin
///
class ReportAdminListTile extends StatelessWidget {
  const ReportAdminListTile({
    super.key,
    required this.snapshot,
    this.from = From.unviewed,
  });

  final DataSnapshot snapshot;
  final From from;

  @override
  Widget build(BuildContext context) {
    print("ReportAdminListTile build: ${Report.reportsRef.path}");

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
            onTap: () => onTap(context, post.uid, post: post, report: report),
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
            onTap: () =>
                onTap(context, comment.uid, comment: comment, report: report),
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
        onTap: () => onTap(
          context,
          report.otherUserUid!,
          user: User.fromUid(report.otherUserUid!),
          report: report,
        ),
      );
    }
  }

  onTap(
    BuildContext context,
    String uid, {
    User? user,
    Post? post,
    Comment? comment,
    required Report report,
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
            if (report.review.isNotEmpty) ...{
              Text(report.review),
              const SizedBox(
                height: 16,
              ),
            },
            Wrap(
              spacing: 2,
              runSpacing: 2,
              children: [
                ElevatedButton(
                  onPressed: () {
                    UserService.instance
                        .showPublicProfileScreen(context: context, uid: uid);
                  },
                  child: const Text('View Profile'),
                ),
                if (post != null)
                  ElevatedButton(
                    onPressed: () {
                      ForumService.instance
                          .showPostViewScreen(context: context, post: post);
                    },
                    child: const Text('View Post'),
                  ),
                if (comment != null)
                  ElevatedButton(
                    onPressed: () async {
                      final post = await Post.get(
                        category: comment.category,
                        id: comment.postId,
                      );
                      if (post == null) {
                        toast(
                          context: context,
                          message: 'Post not found',
                        );
                        return;
                      }

                      ForumService.instance.showPostViewScreen(
                        context: context,
                        post: post,
                      );
                    },
                    child: const Text('View Post'),
                  ),
                if (from != From.rejeced)
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      final re = await input(
                        context: context,
                        title: 'Reason',
                        hintText: 'Entry why you reject the report',
                      );
                      if (re != null) {
                        dog(re);
                        await Report.evaluate(
                            report: report,
                            review: re,
                            type: ReportType.rejected,
                            from: from);
                      }
                    },
                    child: const Text('Reject'),
                  ),
                if (from != From.accepted)
                  ElevatedButton(
                    onPressed: () async {
                      final re = await input(
                        context: context,
                        title: 'Reason',
                        hintText: 'Entry why you accept the report',
                      );
                      if (re != null) {
                        await Report.evaluate(
                          report: report,
                          review: re,
                          type: ReportType.accepted,
                          from: from,
                        );
                      }
                    },
                    child: const Text('Accept'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
