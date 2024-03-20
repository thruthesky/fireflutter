import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// PostLatestListView
///
/// StreamBuilder 위젯으로 가장 최근의 몇 개 글을 가져와 화면에 보여준다.
class PostLatestListView extends StatelessWidget {
  const PostLatestListView({
    super.key,
    required this.category,
    this.limit = 5,
    required this.itemBuilder,
  });

  final String category;
  final int limit;
  final Widget Function(Post) itemBuilder;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Post>>(
      future: Post.latestSummary(category: category, limit: limit),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error');
        }
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        final posts = snapshot.data as List<Post>;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            if (post.deleted) {
              return const SizedBox.shrink();
            }
            return itemBuilder(post);
          },
        );
      },
    );
  }
}
