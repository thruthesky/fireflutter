import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PostViewMeta extends StatelessWidget {
  const PostViewMeta({
    super.key,
    this.post,
  });

  final Post? post;

  @override
  Widget build(BuildContext context) {
    return post == null
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.fromLTRB(
              sizeSm,
              sizeXs,
              sizeSm,
              0,
            ),
            child: Row(
              children: [
                UserAvatar(
                  size: 40,
                  radius: 20,
                  uid: post!.uid,
                  key: ValueKey(post!.uid),
                  onTap: () => UserService.instance.showPublicProfileScreen(
                      context: context, uid: post!.uid),
                ),
                UserDisplayName(
                  uid: post!.uid,
                ),
                const Spacer(),
                DateTimeText(
                  dateTime: post!.createdAt,
                  type: DateTimeTextType.short,
                ),
              ],
            ),
          );
  }
}
