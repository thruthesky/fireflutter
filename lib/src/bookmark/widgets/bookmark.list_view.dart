import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// Bookmark List View
///
/// [emptyBuilder] is a builder for when there are no bookmarks.
class BookmarkListView extends StatelessWidget {
  const BookmarkListView({
    super.key,
    this.padding,
    this.separatorBuilder,
    this.emptyBuilder,
  });

  final EdgeInsets? padding;
  final Widget Function(BuildContext, int)? separatorBuilder;
  final Widget Function()? emptyBuilder;

  @override
  Widget build(BuildContext context) {
    return FirebaseDatabaseQueryBuilder(
      query: Bookmark.bookmarksRef.child(myUid!),
      builder: (context, snapshot, _) {
        if (snapshot.isFetching) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Something went wrong! ${snapshot.error}');
        }

        if (snapshot.docs.isEmpty) {
          return emptyBuilder?.call() ??
              Center(child: Text(T.thereAreNoBookmarksInTheList.tr));
        }

        return ListView.separated(
          itemBuilder: (_, i) {
            final Bookmark bookmark = Bookmark.fromJson(
                snapshot.docs[i].value as Map, snapshot.docs[i].key!);
            return builder(bookmark);
          },
          separatorBuilder: (_, i) =>
              separatorBuilder?.call(_, i) ?? const SizedBox(height: 8),
          itemCount: snapshot.docs.length,
        );
      },
    );
  }

  Widget builder(Bookmark bookmark) {
    if (bookmark.isPost) {
      return FutureBuilder<Post?>(
        future: Post.get(category: bookmark.category!, id: bookmark.postId!),
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
  }
}
