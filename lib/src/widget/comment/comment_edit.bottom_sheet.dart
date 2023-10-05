import 'dart:async';

import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// CommentEditBottomSheet
///
/// Display a bottom shee for createing or updating a comment.
///
/// Get the post from [widget.post] or postId from the [widget.parent] or
/// [widget.comment] to reflect the latest update of the post. It maybe needed
/// if the post is updated by other users like no of comments.
///
///
///
///
class CommentEditBottomSheet extends StatefulWidget {
  const CommentEditBottomSheet({
    super.key,
    this.post,
    this.parent,
    this.comment,
    this.labelText,
    this.hintText,
    this.onEdited,
  });

  final Post? post;
  final Comment? parent;

  /// The comment to be updated.
  /// Add this if you want to update a comment.
  /// [post] should be null if this has value.
  final Comment? comment;
  final String? labelText;
  final String? hintText;

  /// This function will be called when the comment is edited including create and update.
  final Function(Comment comment)? onEdited;

  @override
  State<CommentEditBottomSheet> createState() => CommentBoxState();
}

class CommentBoxState extends State<CommentEditBottomSheet> {
  TextEditingController content = TextEditingController();

  bool get isCreate => widget.comment == null;
  bool get isUpdate => !isCreate;

  double? progress;
  List<String> urls = [];

  /// On comment creation, the latest [noOfComments] is needed. Or [the issue](https://github.com/thruthesky/grc/issues/22) will happen.
  Post? post;
  StreamSubscription? postSubscription;

  @override
  void initState() {
    super.initState();
    if (widget.comment != null) {
      content.text = widget.comment!.content;
      urls = widget.comment!.urls;
    }

    /// [widget.post] has value on comment creation.
    ///
    /// See [the issue](https://github.com/thruthesky/grc/issues/22)
    if (widget.post != null) {
      post = widget.post;
      postSubscription = postDoc(post!.id).snapshots().listen((event) {
        if (event.exists) {
          post = Post.fromDocumentSnapshot(event);
        }
      });
    }
  }

  @override
  void dispose() {
    postSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            UserAvatar(
              uid: myUid!,
              key: ValueKey(myUid!),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: TextField(
                  controller: content,
                  minLines: 2,
                  maxLines: 5,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: widget.labelText ?? 'Comment',
                    hintText: widget.hintText ?? 'Write a comment...',
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.photo),
              onPressed: () async {
                final url = await StorageService.instance.upload(
                  context: context,
                  progress: (p) => setState(() => progress = p),
                  complete: () {
                    progress = null;
                  },
                  camera: CommentService.instance.uploadFromCamera,
                  gallery: CommentService.instance.uploadFromGallery,
                  file: CommentService.instance.uploadFromFile,
                );

                if (url != null && mounted) {
                  setState(() {
                    urls.add(url);
                  });
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () async {
                if (content.text.isEmpty && urls.isEmpty) {
                  return warningSnackbar(context, 'Please input a comment.');
                }

                Comment comment;
                if (isCreate) {
                  comment = await Comment.create(
                    post: post!,
                    parent: widget.parent,
                    content: content.text,
                    urls: urls,
                  );
                } else {
                  comment = await widget.comment!.update(
                    content: content.text,
                    urls: urls,
                  );
                }
                content.text = '';
                if (widget.onEdited != null) {
                  await widget.onEdited!(comment);
                }
              },
            ),
          ],
        ),
        // uploading pregress bar
        if (progress != null) ...[
          const SizedBox(height: 4),
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 20),
        ],
        EditMultipleMedia(
          urls: urls,
          onDelete: (e) async {
            await StorageService.instance.delete(e);
            setState(() {
              urls.remove(e);
            });
          },
        ),
      ],
    );
  }
}
