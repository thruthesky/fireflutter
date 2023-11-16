import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/widget/common/display_uploaded_files.dart';
import 'package:flutter/material.dart';

/// Dispaly a comment in a screen
///
/// Display a button to open the origin post screen.
class CommentViewScreen extends StatefulWidget {
  static const String routeName = '/CommentView';
  const CommentViewScreen({
    super.key,
    this.comment,
    this.commentId,
  });

  final Comment? comment;
  final String? commentId;

  @override
  State<CommentViewScreen> createState() => _CommentViewScreenState();
}

class _CommentViewScreenState extends State<CommentViewScreen> {
  Comment? comment;
  Post? post;

  @override
  void initState() {
    super.initState();
    if (comment != null) {
      comment = comment;
      initPost();
    } else {
      (() async {
        comment = await Comment.get(widget.commentId!);
        initPost();
      })();
    }
  }

  void initPost() async {
    if (comment == null) return;
    post = await PostService.instance.get(comment!.postId);
    dog('Post Got: $post');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comment View'),
      ),
      body: comment == null
          ? const CircularProgressIndicator.adaptive()
          : Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.fromLTRB(sizeSm, sizeSm, sizeSm, sizeMd),
                  margin: const EdgeInsets.all(sizeSm),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(sizeSm),
                    color:
                        Theme.of(context).colorScheme.secondary.withAlpha(20),
                  ),
                  child: Row(
                    children: [
                      UserAvatar(
                        uid: comment!.uid,
                        radius: 10,
                        size: 24,
                        onTap: () =>
                            UserService.instance.showPublicProfileScreen(
                          context: context,
                          uid: comment!.uid,
                        ),
                      ),
                      const SizedBox(width: sizeXs),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: UserDisplayName(
                                  uid: comment!.uid,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      Theme.of(context).textTheme.labelMedium,
                                ),
                              ),
                              const SizedBox(width: sizeXs),
                              DateTimeText(
                                dateTime: comment!.createdAt,
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    fontSize: 11),
                              ),
                            ],
                          ),
                          // photos of the comment
                          DisplayUploadedFiles(
                              otherUid: comment!.uid, urls: comment!.urls),
                          CommentContent(
                            comment: comment!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                          ),
                        ],
                      )),
                    ],
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      PostService.instance.showPostViewScreen(
                          context: context, postId: comment!.postId);
                    },
                    child: const Text('Open post'))
              ],
            ),
    );
  }
}
