import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ReportMyListView extends StatelessWidget {
  const ReportMyListView({super.key});

  @override
  Widget build(BuildContext context) {
    print("ReportMyListView build: ${Report.unviewedRef.path}");
    return FirebaseDatabaseListView(
      query: Report.unviewedRef.orderByChild('uid').equalTo(myUid!),
      errorBuilder: (context, error, stackTrace) {
        dog("Error: $error");
        return Center(
          child: Text('Error: $error'),
        );
      },
      itemBuilder: (context, snapshot) {
        final Report report = Report.fromValue(snapshot.value, snapshot.ref);

        if (report.isPost) {
          return FutureBuilder<Post?>(
            future: Post.get(
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
          return FutureBuilder<Comment?>(
            future: Comment.get(
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
                    // path: ChatRoom.chatRoomName(report.chatRoomId),
                    ref: ChatRoom.nameRef(report.chatRoomId!),
                    builder: (v) {
                      // no name is null on chat-rooms/chatid/name
                      // Explanation: Name is null because chat room can be a single
                      //              Chat Room, which doesn't usually have Chat
                      //              Room Name.
                      return Text(v ?? 'No Chat Room Name');
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
                UserDisplayName(uid: report.otherUserUid!),
                Text(' ${report.createdAt.toShortDate}'),
              ],
            ),
            trailing: IconButton(
                key: Key('reportUser${report.otherUserUid}'),
                onPressed: () async {
                  final re = await confirm(
                      context: context,
                      title: 'Delete report',
                      message: 'Do you want to delete this report?');
                  if (re != true) return;
                  await report.ref.remove();
                },
                icon: const Icon(Icons.delete)),
          );
        }
      },
    );
  }
}
