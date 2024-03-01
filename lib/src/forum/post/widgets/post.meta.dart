import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PostMeta extends StatelessWidget {
  const PostMeta({
    super.key,
    required this.post,
  });

  final PostModel post;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          UserAvatar(
            uid: post.uid,
            onTap: () => UserService.instance.showPublicProfileScreen(
              context: context,
              uid: post.uid,
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserDisplayName(
                uid: post.uid,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(width: 8),
              DateTimeShort(dateTime: post.createdAt),
            ],
          ),
        ],
      ),
    );
  }
}
