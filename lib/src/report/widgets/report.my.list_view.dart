import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ReportMyListView extends StatelessWidget {
  const ReportMyListView({
    super.key,
    this.userBuilder,
    this.postBuilder,
    this.commentBuilder,
    this.chatBuilder,
    this.errorBuilder,
    this.loadingBuilder,
    this.emptyBuilder,
  });

  final Widget Function(Report report, VoidCallback func)? userBuilder;
  final Widget Function(Report report, Post post, VoidCallback func)?
      postBuilder;
  final Widget Function(Report report, Comment commnet, VoidCallback func)?
      commentBuilder;
  final Widget Function(Report report, VoidCallback func)? chatBuilder;

  final Widget Function(
          BuildContext context, dynamic error, StackTrace? stackTrace)?
      errorBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;

  @override
  Widget build(BuildContext context) {
    print("ReportMyListView build: ${Report.unviewedRef.path}");
    // change FirebaseDatabaseListview to FirebaseDatabaseQueryBuilder
    return FirebaseDatabaseQueryBuilder(
        query: Report.unviewedRef.orderByChild('uid').equalTo(myUid!),
        builder: (context, snapshot, index) {
          if (snapshot.hasError) {
            return errorBuilder?.call(
                    context, snapshot.error, snapshot.stackTrace) ??
                Text("report error: ${snapshot.error}");
          }
          if (snapshot.isFetching) {
            return loadingBuilder?.call(context) ??
                const Center(child: CircularProgressIndicator());
          }

          if (snapshot.docs.isEmpty) {
            return emptyBuilder?.call(context) ??
                const Center(child: Text("No reports"));
          }
          return ListView.builder(
              itemCount: snapshot.docs.length,
              itemBuilder: (context, index) {
                if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
                  // Tell FirestoreQueryBuilder to try to obtain more items.
                  // It is safe to call this function from within the build method.
                  snapshot.fetchMore();
                  dog("fetching more users");
                }
                final Report report = Report.fromValue(
                    snapshot.docs[index].value, snapshot.docs[index].ref);

                func() async {
                  final re = await confirm(
                      context: context,
                      title: 'Delete report',
                      message: 'Do you want to delete this report?');
                  if (re != true) return;
                  await report.ref.remove();
                }

                if (report.isPost) {
                  return FutureBuilder<Post?>(
                    future: Post.get(
                      category: report.category!,
                      id: report.postId!,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator.adaptive());
                      }
                      final post = snapshot.data!;
                      return postBuilder?.call(report, post, func) ??
                          ListTile(
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
                            trailing: IconButton(
                              key: Key('reportUser${report.otherUserUid}'),
                              onPressed: func,
                              icon: const Icon(Icons.delete),
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
                        return const Center(
                            child: CircularProgressIndicator.adaptive());
                      }
                      final comment = snapshot.data!;
                      return commentBuilder?.call(report, comment, func) ??
                          ListTile(
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
                            trailing: IconButton(
                              key: Key('reportUser${report.otherUserUid}'),
                              onPressed: func,
                              icon: const Icon(Icons.delete),
                            ),
                          );
                    },
                  );
                } else if (report.isChatRoom) {
                  dog('${report.chatRoomId} ${report.otherUserUid} ');

                  final room = ChatRoom.fromUid(report.otherUserUid!);
                  return chatBuilder?.call(report, func) ??
                      ListTile(
                        title: Text(report.reason),
                        subtitle: Row(
                          children: [
                            if (room.isSingleChat) ...{
                              const Text('[CHAT] '),
                              Value.once(
                                  // path: ChatRoom.chatRoomName(report.chatRoomId),
                                  ref: ChatJoin.nameRef(report.chatRoomId!),
                                  builder: (v) {
                                    // no name is null on chat-rooms/chatid/name
                                    // Explanation: Name is null because chat room can be a single
                                    //              Chat Room, which doesn't usually have Chat
                                    //              Room Name.
                                    return Text(v ?? 'No Chat Room Name');
                                  }),
                            } else ...{
                              const Text('[GROUP CHAT] '),
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
                            },
                            Text(' ${report.createdAt.toShortDate}'),
                          ],
                        ),
                        trailing: IconButton(
                          key: Key('reportUser${report.otherUserUid}'),
                          onPressed: func,
                          icon: const Icon(Icons.delete),
                        ),
                      );
                } else {
                  return userBuilder?.call(report, func) ??
                      ListTile(
                        leading: UserAvatar(
                          uid: report.otherUserUid!,
                        ),
                        title: Text(report.reason),
                        subtitle: Row(
                          children: [
                            UserDisplayName(uid: report.otherUserUid!),
                            Text(' ${report.createdAt.toShortDate}'),
                          ],
                        ),
                        trailing: IconButton(
                          key: Key('reportUser${report.otherUserUid}'),
                          onPressed: func,
                          icon: const Icon(Icons.delete),
                        ),
                      );
                }
              });
        });
  }
}
