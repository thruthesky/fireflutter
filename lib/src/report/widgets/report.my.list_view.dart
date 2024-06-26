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
    this.separatorBuilder,
    this.padding,
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

  final Widget Function(BuildContext, int)? separatorBuilder;

  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    print("ReportMyListView build: ${Report.unviewedRef.path}");
    // To have a emptybuilder need to be FirebaseDatabaseQueryBuilder
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
                Center(
                  child: Text(
                    T.noReport.tr,
                  ),
                );
          }
          return ListView.separated(
              padding: padding ?? const EdgeInsets.all(8),
              separatorBuilder: (_, index) =>
                  separatorBuilder?.call(_, index) ?? const SizedBox.shrink(),
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
                      title: T.deleteReport.tr,
                      message: T.doYouWantToDeleteReport.tr);
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
                                Text('[${T.comment.tr.toUpperCase()}] '),
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
                  dog(' report.isChatRoom::  ${report.chatRoomId} ${report.otherUserUid} ');

                  final room = ChatRoom.fromRoomdId(report.chatRoomId!);
                  return chatBuilder?.call(report, func) ??
                      ListTile(
                        leading: room.isSingleChat
                            ? UserAvatar(uid: room.otherUserUid!)
                            : ChatRoomAvatar(room: room),
                        title: Text(report.reason),
                        subtitle: Row(
                          children: [
                            if (room.isSingleChat) ...{
                              Text('[${T.chat.tr.toUpperCase()}] '),
                              Value.once(
                                  // path: ChatRoom.chatRoomName(report.chatRoomId),
                                  ref: ChatJoin.nameRef(report.chatRoomId!),
                                  builder: (v) {
                                    // no name is null on chat-rooms/chatid/name
                                    // Explanation: Name is null because chat room can be a single
                                    //              Chat Room, which doesn't usually have Chat
                                    //              Room Name.
                                    return Text(v ?? T.noChatRoomName.tr);
                                  }),
                            } else ...{
                              Text('[${T.groupChat.tr.toUpperCase()}] '),
                              Value.once(
                                  // path: ChatRoom.chatRoomName(report.chatRoomId),
                                  ref: ChatRoom.nameRef(report.chatRoomId!),
                                  builder: (v) {
                                    // no name is null on chat-rooms/chatid/name
                                    // Explanation: Name is null because chat room can be a single
                                    //              Chat Room, which doesn't usually have Chat
                                    //              Room Name.
                                    return Expanded(
                                      child: Text(
                                        v ?? T.noChatRoomName.tr,
                                        maxLines: 1,
                                        overflow: TextOverflow.clip,
                                      ),
                                    );
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
