import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class BookmarkListView extends StatelessWidget {
  const BookmarkListView({super.key});

  @override
  Widget build(BuildContext context) {
    return FirebaseDatabaseListView(
      query: BookmarkModel.bookmarksRef.child(myUid!),
      itemBuilder: (context, snapshot) {
        final BookmarkModel bookmark =
            BookmarkModel.fromValue(snapshot.value, snapshot.key!);

        if (bookmark.isPost) {
          return FutureBuilder<PostModel?>(
            future: PostModel.get(
                category: bookmark.category!, id: bookmark.postId!),
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
                title: Text(post.title),
                subtitle: Row(
                  children: [
                    const Text('[POST] '),
                    UserDoc.field(
                      uid: post.uid,
                      field: 'displayName',
                      builder: (name) => Text(name ?? ''),
                    ),
                    Text(' ${post.createdAt.toLocal()}'),
                  ],
                ),
                onTap: () => ForumService.instance.showPostViewScreen(
                  context,
                  post: post,
                ),
              );
            },
          );
        } else if (bookmark.isComment) {
          return FutureBuilder<CommentModel?>(
            future: CommentModel.get(
              postId: bookmark.postId!,
              commentId: bookmark.commentId!,
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
                title: Text(comment.content),
                subtitle: Row(
                  children: [
                    const Text('[COMMNET] '),
                    UserDoc.field(
                      uid: comment.uid,
                      field: 'displayName',
                      builder: (name) => Text(name ?? ''),
                    ),
                    Text(' ${comment.createdAt.toShortDate}'),
                  ],
                ),
                onTap: () async {
                  final post = await PostModel.get(
                      category: comment.category, id: comment.postId);
                  if (context.mounted) {
                    ForumService.instance.showPostViewScreen(
                      context,
                      post: post!,
                    );
                  }
                },
              );
            },
          );
        } else {
          return ListTile(
            leading: UserAvatar(uid: bookmark.otherUserUid!),
            subtitle: Row(
              children: [
                UserDisplayName(uid: bookmark.otherUserUid!),
              ],
            ),
          );
        }
      },
    );
  }
}
