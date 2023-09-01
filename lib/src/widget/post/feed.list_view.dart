import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class FeedListView extends StatelessWidget {
  const FeedListView({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FeedService.instance.getAllByMinusDate(),
      builder: (context, snapshot) {
        final posts = snapshot.data ?? [];
        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return ListTile(
              title: Text(post.title),
              subtitle: Text(
                post.content.replaceAll('\n', ' '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                PostService.instance.showPostViewDialog(context, post);
              },
            );
          },
        );
      },
    );
  }
}
