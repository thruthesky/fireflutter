import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class BookmarkListView extends StatelessWidget {
  const BookmarkListView({
    super.key,
    this.padding,
  });

  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return FirebaseDatabaseListView(
      padding: padding ?? const EdgeInsets.all(8),
      query: Bookmark.bookmarksRef.child(myUid!),
      itemBuilder: (context, snapshot) {
        final Bookmark bookmark =
            Bookmark.fromValue(snapshot.value, snapshot.key!);

        if (bookmark.isPost) {
          return FutureBuilder<Post?>(
            future:
                Post.get(category: bookmark.category!, id: bookmark.postId!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator.adaptive();
              }
              final post = snapshot.data!;
              return ListTile(
                leading: UserAvatar(uid: post.uid),
                title: Text(post.title),
                subtitle: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('[POST] '),
                    UserDoc.field(
                      uid: post.uid,
                      field: 'displayName',
                      builder: (name) => Text(name ?? ''),
                    ),
                    Text(' ${post.createdAt.toYmd}'),
                  ],
                ),
                onTap: () => ForumService.instance.showPostViewScreen(
                  context: context,
                  post: post,
                ),
              );
            },
          );
        } else if (bookmark.isComment) {
          return FutureBuilder<Comment?>(
            future: Comment.get(
              postId: bookmark.postId!,
              commentId: bookmark.commentId!,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator.adaptive();
              }
              final comment = snapshot.data!;
              return ListTile(
                leading: UserAvatar(uid: comment.uid),
                title: Text(comment.content),
                subtitle: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                  final post = await Post.get(
                      category: comment.category, id: comment.postId);
                  if (context.mounted) {
                    ForumService.instance.showPostViewScreen(
                      context: context,
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
